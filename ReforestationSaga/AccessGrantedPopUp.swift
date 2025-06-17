//
//  LevelCompletePopUp.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct AccessGrantedPopUp: View {
    
    var body: some View {
        ZStack {
            Image("questbox")
                .resizable()
                .frame(width: 329, height: 122)
            
            Text("Access Granted!")
                .font(Font.custom("Gugi", size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .frame(width: 306, alignment: .top)
                .padding(.bottom, 31)
            
            Text("Iris biometric match confirmed.")
                .font(
                    Font.custom("Genos", size: 17)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.top,81)
                .padding(.bottom,37)
        }
    }
}

#Preview {
    AccessGrantedPopUp()
}
