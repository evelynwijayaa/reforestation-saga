//
//  BlinkAlert.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct BlinkAlert: View {
    var body: some View {
        VStack {
            ZStack {
                Image("initialalert")
                    .resizable()
                    .frame(width: 350, height: 41)
                
                Text("Trees can not be planted on the ocean")
                  .font(
                    Font.custom("Genos", size: 18)
                        .weight(.medium)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                  .frame(width: 350, alignment: .top)
                  .padding(.bottom, 10)
            }
    }
    }
}

#Preview {
    BlinkAlert()
        .padding()
//        .background(.black.opacity(0.5))
}
