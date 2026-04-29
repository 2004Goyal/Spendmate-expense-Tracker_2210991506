//
//  DashboardModel.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 10/07/25.
//

import Foundation
import SwiftUI
import Charts
import UIKit
import Combine

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("Charcoal"))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color("Charcoal"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100) // FIXED: Set both min and max height
        .background(Color("MistyAqua"))
        .cornerRadius(12)
    }
}

// MARK: - Spend Bar
struct SpendBar: View {
    var category: String
    var amount: Int
    var limit: Int
    var color: Color

    var body: some View {
        HStack {
            Text(category)
                .foregroundColor(Color("Charcoal"))
                .frame(width: 100, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 10)

                    Capsule()
                        .fill(amount > limit ? Color.red : color)
                        .frame(width: geo.size.width * CGFloat(min(Double(amount) / Double(limit == 0 ? 1 : limit), 1.0)), height: 10)
                }
            }
            .frame(height: 10)

            Text("₹\(amount)")
                .foregroundColor(Color("Charcoal"))
                .frame(width: 70, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.subheadline)
    }
}

// MARK: - Dashboard Button (keeping original)
struct DashboardButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("CaribbeanTeal"))
        .cornerRadius(12)
    }
}



//Challenge Model


//Report View Model
struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Image(systemName: title == "Income" ? "arrow.up" : (title == "Expenses" ? "arrow.down" : "arrow.right"))
                Text(title).font(.caption)
            }
            .foregroundColor(color)

            Text(value)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("MistyAqua"))
        .cornerRadius(12)
    }
}
//////
struct TopSpenderCard: View {
    var name: String
    var amount: String
    var percent: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            VStack(alignment: .leading) {
                Text(name).foregroundColor(.black)
                Text(amount)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(percent)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
//////
struct DonutChartView: View {
    let data: [(String, Double, Color)]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Chart {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        SectorMark(
                            angle: .value("Value", item.1),
                            innerRadius: .ratio(0.6),
                            angularInset: 1
                        )
                        .foregroundStyle(item.2)
                    }
                }
                .frame(height: 220)

                ForEach(0..<data.count, id: \.self) { i in
                    let angle = startAngle(for: i)
                    let radius: CGFloat = 130
                    let labelOffset = CGPoint(
                        x: radius * cos(angle),
                        y: radius * sin(angle)
                    )

                    VStack(alignment: angle > .pi/2 && angle < 3 * .pi/2 ? .trailing : .leading, spacing: 2) {
                        Text(data[i].0)
                            .font(.caption)
                            .bold()
                            .foregroundColor(data[i].2)
                            .padding(4)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(6)

                        Text("(\(Int(data[i].1))%)")
                            .font(.caption2)
                            .foregroundColor(.black)
                            .padding(3)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(5)
                    }
                    .position(x: geo.size.width / 2 + labelOffset.x,
                              y: geo.size.height / 2 + labelOffset.y)
                }
            }
        }
        .frame(height: 260)
    }

    func startAngle(for index: Int) -> CGFloat {
        let total = data.map { $0.1 }.reduce(0, +)
        let angles = data.map { $0.1 / total * 2 * .pi }
        let halfAngle = angles[index] / 2
        let start = angles.prefix(index).reduce(0, +)
        return CGFloat(start + halfAngle - .pi / 2)
    }
}
