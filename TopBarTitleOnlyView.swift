//
//  CardView.swift
//  SpendMate
//
//  Created by Dhruv Goyal on 22/06/25.
//

import Foundation
import SwiftUI

struct TopBarTitleOnlyView: View {
    var title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title3) // Match heading style
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color("PeacockBlue"))
    }
}

