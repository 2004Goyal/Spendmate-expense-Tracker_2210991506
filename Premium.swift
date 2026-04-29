//
//  Premium.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 14/07/25.
//

import Foundation
import SwiftUI

struct PremiumPlansView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false
    @AppStorage("premiumExpiryDate") private var premiumExpiryDate: Double = 0
    @State private var selectedPlan: Plan? = nil
    @State private var showPaymentSheet = false

    struct Plan: Identifiable {
        let id = UUID()
        let duration: String
        let price: String
        let months: Int
    }

    let plans: [Plan] = [
        .init(duration: "3 Months",  price: "₹400", months: 3),
        .init(duration: "6 Months",  price: "₹700", months: 6),
        .init(duration: "12 Months", price: "₹600", months: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Upgrade").font(.largeTitle.bold())

                    Text("Choose Your Premium Plan")
                        .font(.title3).foregroundColor(.gray)

                    ForEach(plans) { plan in
                        Button {
                            selectedPlan = plan
                            showPaymentSheet = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                        Text(plan.duration).font(.headline).fontWeight(.semibold)
                                    }
                                    Text("Unlock all premium features.").font(.caption)
                                }

                                Spacer()
                                Text(plan.price).font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [Color("PeacockBlue"), Color("CaribbeanTeal")], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaymentSheet) {
                if let plan = selectedPlan {
                    PaymentScreen(plan: plan)
                }
            }
        }
    }
}
