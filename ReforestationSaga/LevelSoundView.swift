//
//  LevelSoundView.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct LevelSoundView: View {
    @Binding var isMuted: Bool
    @EnvironmentObject var gameData: GameData
    var currentLevel: Int
    var scene: GameScene?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("Highest Level: \(gameData.highestLevel)")
                .font(Font.custom("Gugi", size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                .padding(.bottom, 8)
//                .background(.white)
           
            ZStack {
                Image("box")
                    .resizable()
                    .frame(width: 100, height: 40)
//                    .background(.red)
                Text("LEVEL \(currentLevel)")
                    .font(Font.custom("Gugi", size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                    .padding(.bottom, 8)
            }
            .offset(x: 4)
            
            Button {
                isMuted.toggle()
                if isMuted {
                    scene?.pauseMusic()
                } else {
                    scene?.resumeMusic()
                }
            } label: {
                Image(isMuted ? "soundoff" :"sound")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding(.top, -6)
                    .offset(x: 4)
            }
//            .background()
        }
    }
}

#Preview {
    LevelSoundPreview()
}

struct LevelSoundPreview: View {
    @State private var isMuted = false

    var body: some View {
        LevelSoundView(isMuted: $isMuted,
                       currentLevel: 1,
                       scene: nil)
            .padding()
            .background(Color.black) // opsional biar kontras
            .environmentObject(GameData())
    }
}
