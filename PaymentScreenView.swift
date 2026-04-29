//
//  PaymentScreenView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 14/07/25.
//

import Foundation
import SwiftUI

struct PaymentScreen: View {
    let plan: PremiumPlansView.Plan
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false
    @AppStorage("premiumExpiryDate") private var premiumExpiryDate: Double = 0
    @Environment(\.dismiss) var dismiss

    @State private var selectedMethod: String? = nil
    @State private var isProcessing = false
    @State private var showSuccess = false

    let methods = ["Card", "UPI", "Net Banking"]

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Pay \(plan.price)")
                    .font(.largeTitle.bold())
                    .padding(.top)

                Text("Select a payment method")
                    .font(.headline)
                    .foregroundColor(.gray)

                ForEach(methods, id: \.self) { method in
                    Button(action: {
                        selectedMethod = method
                        simulatePaymentFlow()
                    }) {
                        HStack {
                            Image(systemName: iconForMethod(method))
                                .font(.title2)
                            Text(method)
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("PeacockBlue").opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                }

                Spacer()
            }
            .padding()
            .blur(radius: (isProcessing || showSuccess) ? 10 : 0)
            .disabled(isProcessing || showSuccess)

            if isProcessing {
                ProcessingView()
            }

            if showSuccess {
                Color.black.opacity(0.4).ignoresSafeArea()
                SuccessAnimationView()
                    .transition(.scale)
            }
        }
    }

    func simulatePaymentFlow() {
        isProcessing = true

        // Step 1: Show Processing for 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            withAnimation(.easeOut(duration: 0.5)) {
                showSuccess = true
            }

            // Step 2: Finalize and dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                isPremiumUser = true
                if let expiry = Calendar.current.date(byAdding: .month, value: plan.months, to: .now) {
                    premiumExpiryDate = expiry.timeIntervalSince1970
                }
                dismiss()
            }
        }
    }

    func iconForMethod(_ method: String) -> String {
        switch method {
        case "Card": return "creditcard.fill"
        case "UPI": return "indianrupee.circle.fill"
        case "Net Banking": return "building.columns.fill"
        default: return "circle"
        }
    }
}

// MARK: - Processing View
struct ProcessingView: View {
    @State private var isRotating = false

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)

            Text("Processing Payment...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(40)
        .background(BlurView(style: .systemUltraThinMaterialDark))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// MARK: - Success Animation View
struct SuccessAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                        scale = 1.2
                        opacity = 1.0
                    }
                }

            Text("Payment Successful!")
                .font(.title2.bold())
                .foregroundColor(.green)
        }
        .padding()
        .background(BlurView(style: .systemUltraThinMaterialLight))
        .cornerRadius(20)
        .shadow(radius: 6)
    }
}

// MARK: - UIKit Blur View for SwiftUI
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

