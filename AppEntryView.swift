//
//  AppEntryView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 17/08/25.
//

import Foundation
import SwiftUI

// MARK: - Entry: Splash → SignIn (with hero animation)
struct AppEntryView: View {
    @Namespace private var smHero
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            // Keep SignIn behind so we can handoff smoothly via matched geometry
            SignInView(heroNamespace: smHero)
                .opacity(showSignIn ? 1 : 0)

            if !showSignIn {
                SplashHero(ns: smHero) {
                    withAnimation(.spring(response: 0.9, dampingFraction: 0.88)) {
                        showSignIn = true
                    }
                }
                .transition(.identity) // preserve hero continuity
            }
        }
        .background(Color(hex: "#D4F1F4").ignoresSafeArea())
    }
}

// MARK: - Splash with outline-shine following the S boundary
struct SplashHero: View {
    let ns: Namespace.ID
    let onDone: () -> Void

    @State private var appear = false
    @State private var orbit  = false
    @State private var exitPhase = false

    var body: some View {
        ZStack {
            // Subtle animated background gradient
            AnimatedBG().ignoresSafeArea()

            // Ambient pulse rings behind the logo
            ZStack {
                PulseRing(radius: 120, delay: 0.0)
                PulseRing(radius: 165, delay: 0.35)
                PulseRing(radius: 215, delay: 0.7)
            }
            .opacity(0.45)

            // Orbiting dots (parallax feel)
            OrbitingDots(active: orbit)
                .frame(width: 250, height: 250)
                .opacity(0.75)

            // === The Mark + OUTLINE SHINE traced along the S ===
            ZStack {
                // Animated shine that uses the logo's edge as a mask
                ShinyLogoBorder(
                    imageName: "SpendMateMark",
                    size: 240,
                    thickness: 2.2,
                    highlightColors: [
                        .white.opacity(0.0),
                        .white.opacity(0.95),
                        .white.opacity(0.55),
                        .white.opacity(0.0)
                    ],
                    baseTint: Color(hex: "#2CB6B3")
                )
                .opacity(0.98)

                Image("SpendMateMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .matchedGeometryEffect(id: "sm_logo", in: ns)
                    .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 8)
                    .scaleEffect(appear ? 1.0 : 0.9)
                    .rotation3DEffect(.degrees(exitPhase ? -12 : 0), axis: (x: 1, y: 0, z: 0))
                    .offset(y: exitPhase ? -10 : 0)
                    .animation(.spring(response: 0.9, dampingFraction: 0.85), value: exitPhase)
                    .animation(.spring(response: 0.7, dampingFraction: 0.85), value: appear)
            }
            .opacity(appear ? 1 : 0)
            .animation(.easeOut(duration: 0.45), value: appear)
        }
        .onAppear {
            if UIAccessibility.isReduceMotionEnabled {
                onDone(); return
            }
            appear = true
            orbit = true

            // Let users actually look (~1.8s ambient)
            let dwell: Double = 1.8

            // Handoff (tilt + lift)
            DispatchQueue.main.asyncAfter(deadline: .now() + dwell) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.86)) {
                    exitPhase = true
                }
            }
            // Route to SignIn (hero takes over)
            DispatchQueue.main.asyncAfter(deadline: .now() + dwell + 0.6) {
                onDone()
            }
        }
    }
}

// MARK: - Outline Shine that follows the logo boundary
/// Builds a thin ring mask from the image alpha using Canvas (blur + threshold, minus inner blur),
/// then spins an AngularGradient through only that ring.
struct ShinyLogoBorder: View {
    let imageName: String
    var size: CGFloat = 240
    var thickness: CGFloat = 2.0
    var highlightColors: [Color] = [.clear, .white, .clear]
    var baseTint: Color = .white.opacity(0.3)

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // 1) Base static tint along the edge (subtle constant outline)
            baseTint
                .mask(
                    LogoEdgeMask(imageName: imageName, thickness: thickness)
                        .frame(width: size, height: size)
                )

            // 2) Animated highlight that rotates around the edge
            AngularGradient(
                gradient: Gradient(colors: highlightColors),
                center: .center
            )
            .rotationEffect(.degrees(rotation))
            .mask(
                LogoEdgeMask(imageName: imageName, thickness: thickness)
                    .frame(width: size, height: size)
            )
        }
        .frame(width: size, height: size)
        .drawingGroup()
        .onAppear {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

/// Produces a white ring where the logo's outline is, using blur/threshold in a Canvas.
/// We blur once (outer) to expand, draw it, then subtract a stronger blur (inner) to hollow
/// the fill into a ring. This mask is perfect to colorize with gradients.
// Produces a white ring where the logo's outline is, using blur/threshold in a Canvas.
// We blur once (outer) to expand, then subtract a stronger blur (inner) to leave a thin ring.
private struct LogoEdgeMask: View {
    let imageName: String
    var thickness: CGFloat = 2.0   // approx ring thickness in points

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                // Resolve the *plain Image* (no frame/scale modifiers here)
                let img = Image(imageName)
                let resolved = context.resolve(img)

                // Target rect ~90% of canvas (centered)
                let scale: CGFloat = 0.9
                let w = size.width * scale
                let h = size.height * scale
                let rect = CGRect(
                    x: (size.width - w) / 2,
                    y: (size.height - h) / 2,
                    width: w,
                    height: h
                )

                // Ring thickness via two blurs
                let outerBlur = max(thickness * 2.0, 2.0)
                let innerBlur = max(thickness * 4.0, 4.0)

                context.drawLayer { layer in
                    // 1) Outer blurred alpha → threshold → white
                    layer.addFilter(.alphaThreshold(min: 0.4, color: .white))
                    layer.addFilter(.blur(radius: outerBlur))
                    layer.draw(resolved, in: rect)

                    // 2) Subtract stronger blur to hollow the fill (destinationOut)
                    layer.blendMode = .destinationOut
                    layer.addFilter(.alphaThreshold(min: 0.4, color: .black))
                    layer.addFilter(.blur(radius: innerBlur))
                    layer.draw(resolved, in: rect)
                }
            }
        }
    }
}


// MARK: - Components used around the mark

/// Slow-shifting background gradient with a soft moving hotspot
private struct AnimatedBG: View {
    @State private var t: CGFloat = 0
    var body: some View {
        LinearGradient(
            colors: [Color(hex: "#D4F1F4"), Color(hex: "#BFECEE"), Color(hex: "#D9F6F6")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [Color.white.opacity(0.24), .clear],
                center: .init(x: 0.32 + 0.1 * sin(t), y: 0.32 + 0.1 * cos(t)),
                startRadius: 10, endRadius: 440
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                t = 2 * .pi
            }
        }
    }
}

/// Expanding, fading ring
private struct PulseRing: View {
    let radius: CGFloat
    let delay: Double
    @State private var anim = false
    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.35), lineWidth: 2)
            .frame(width: radius, height: radius)
            .scaleEffect(anim ? 1.35 : 0.7)
            .opacity(anim ? 0.0 : 1.0)
            .blur(radius: 0.5)
            .onAppear {
                withAnimation(.easeOut(duration: 1.8).delay(delay).repeatForever(autoreverses: false)) {
                    anim = true
                }
            }
    }
}

/// Four dots orbiting the logo
private struct OrbitingDots: View {
    var active: Bool
    @State private var angle: Double = 0
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                let a = angle + Double(i) * 90
                Circle()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 6, height: 6)
                    .offset(x: CGFloat(cos(a * .pi/180)) * 95,
                            y: CGFloat(sin(a * .pi/180)) * 95)
                    .shadow(radius: 1)
            }
        }
        .onChange(of: active) { on in
            if on {
                withAnimation(.linear(duration: 3.2).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
        }
    }
}

