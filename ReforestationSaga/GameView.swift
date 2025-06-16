//
//  GameView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    @StateObject private var detector = EyeBlinkDetectorVision()
    @State private var showAlert = false
    @State private var scene: GameScene?
    @State private var isMuted: Bool = false

    var body: some View {
        ZStack {

            CameraViewVision(eyeBlinkDetector: detector)
                .edgesIgnoringSafeArea(.all)
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: 300, height: 600)
                    .ignoresSafeArea()
            }
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isMuted.toggle()
                        if isMuted {
                            scene?.pauseMusic()
                        } else {
                            scene?.resumeMusic()
                        }
                    } label: {
                        Image(isMuted ? "sound-off" : "sound-on")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    }
                    .padding(.horizontal, 24)
                }
                Spacer()
            }

        }
        .onAppear {
            //            detector.startCamera()
            let newScene = GameScene(size: CGSize(width: 400, height: 800))
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showAlert = true
            }
            self.scene = newScene
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.blinkCount) {
            scene?.shootNeedle()
        }
        .alert("Mission Failed!", isPresented: $showAlert) {
            Button("Try Again", role: .cancel) {}
        } message: {
            Text("Jarum mengenai zona terlarang.")
        }
    }
}

#Preview {
    GameView()
}
