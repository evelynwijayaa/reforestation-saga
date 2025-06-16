//
//  PopUpMission.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct PopUpMission: View {
    var onNextMission: () -> Void
    var body: some View {
        ZStack {
            Image("questbox")
                .resizable()
                .frame(width: 329, height: 139)
            
            Text("Mission Completed!")
              .font(Font.custom("Gugi", size: 35))
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
              .frame(width: 306, alignment: .top)
              .padding(.top,15)
              .padding(.bottom,47)
            
            Text("You Have Saved the Planet")
              .font(
                Font.custom("Genos", size: 20.58992)
                  .weight(.medium)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
              .padding(.top,94)
              .padding(.bottom,24)
        }
        
        Button(action: {
            onNextMission()
        }) {
            ZStack{
                Image("button")
                
                Text("NEXT MISSION")
                    .font(Font.custom("Gugi", size: 25.74193))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.02, green: 0.02, blue: 0.18))
                    .padding(.bottom, 14)
            }
        }
    }
}

#Preview {
    PopUpMission(onNextMission: {print("Next mission tapped!")})
        .padding()
        .background(.black.opacity(0.5))
}
