//
//  GameView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    let scene: GameScene
    @StateObject private var detector = EyeBlinkDetector()

    init() {
        scene = GameScene()
        scene.size = CGSize(width: 300, height: 600)
        scene.scaleMode = .resizeFill
    }

    var body: some View {
        ZStack {
            CameraPreviewView(session: detector.captureSession)
                .edgesIgnoringSafeArea(.all)
            Image("background-level-1")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            //            Text(detector.predictionLabel)
            //                .font(.title)
            //                .foregroundColor(.white)
            //                .padding()
            //                .background(Color.black.opacity(0.6))
            //                .clipShape(RoundedRectangle(cornerRadius: 10))

            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: 300, height: 600)
                .ignoresSafeArea()
        }
        .onAppear {
            detector.startCamera()
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.predictionLabel) {
            scene.triggerAction(detector.predictionLabel)
        }
    }
}

#Preview {
    GameView()
}
