//
//  BarView.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct BarView: View {
    var treesRemaining: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pollution Indicator")
                .font(Font.custom("Gugi", size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.bottom, 8)
//                .background(.white)
           
            Image ("pollution")
            
            Text("Trees Remaining: \(treesRemaining)")
                .font(Font.custom("Gugi", size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.top, 12)
//            .background()
        }
    }
}

#Preview {
    BarView(treesRemaining: 5)
        .padding()
        .background(.black)
}
