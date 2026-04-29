//
//  MainTabView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 04/07/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }

            PlannerView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Planner")
                }

            GroupExpensesView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("SquadPay")
                }

            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
        }
        .accentColor(Color("CaribbeanTeal"))
    }
}
