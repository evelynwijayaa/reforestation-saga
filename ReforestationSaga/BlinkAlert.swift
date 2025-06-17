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
                Image("questbox")
                    .resizable()
                    .frame(width: 329, height: 41)
                
                Text("Blink to launch a tree")
                  .font(
                    Font.custom("Genos", size: 18)
                      .weight(.medium)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                  .frame(width: 272, alignment: .top)
            }
        
        ZStack {
            Image("missionfailedbox")
                .resizable()
                .frame(width: 329, height: 65)
            
            VStack {
                Text("ALERT!")
                    .font(Font.custom("Gugi", size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 1, green: 0.42, blue: 0.36))
                    .frame(width: 272, alignment: .top)
                
                Text("Your face is not detected")
                  .font(
                    Font.custom("Genos", size: 18)
                      .weight(.medium)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(Color(red: 1, green: 0.42, blue: 0.36))
                  .frame(width: 272, alignment: .top)
            }
        }
    }
    }
}

#Preview {
    BlinkAlert()
        .padding()
        .background(.black.opacity(0.5))
}
