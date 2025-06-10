//
//  GameView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    let scene: GameScene

    init() {
        scene = GameScene()
        scene.size = CGSize(width: 300, height: 600)
        scene.scaleMode = .resizeFill
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .frame(width: 300, height: 600)
                .ignoresSafeArea()

        }
    }
}
