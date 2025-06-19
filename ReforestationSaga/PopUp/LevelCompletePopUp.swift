//
//  LevelCompletePopUp.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct LevelCompletePopUp: View {
    var level: Int
    
    var body: some View {
        ZStack {
            Image("questbox")
                .resizable()
                .frame(width: 350, height: 80)
            
            Text("Level \(level) Complete!")
                .font(Font.custom("Gugi", size: 35))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .frame(width: 306, alignment: .top)
        }
    }
}

#Preview {
    LevelCompletePopUp(level: 1)
}
