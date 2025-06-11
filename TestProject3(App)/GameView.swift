//
//  GameView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    @StateObject private var detector = EyeBlinkDetector()
    @State private var showAlert = false
    @State private var scene: GameScene?

    var body: some View {
        ZStack {
            CameraPreviewView(session: detector.captureSession)
                .edgesIgnoringSafeArea(.all)
            Image("background-level-1")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: 300, height: 600)
                    .ignoresSafeArea()
            }
            
        }
        .onAppear {
            detector.startCamera()
            let newScene = GameScene(size: CGSize(width: 400, height: 800))
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showAlert = true
            }
            self.scene = newScene
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.predictionLabel) {
            scene!.triggerAction(detector.predictionLabel)
        }
        .alert("Mission Failed!", isPresented: $showAlert) {
            Button("Try Again", role: .cancel) { }
        } message: {
            Text("Jarum mengenai zona terlarang.")
        }
    }
}

#Preview {
    GameView()
}
