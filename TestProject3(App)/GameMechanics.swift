//
//  Mechanic.swift
//  TestProject3(App)
//
//  Created by Muhammad Irhamdi Fahdiyan Noor on 11/06/25.
//

import SpriteKit
import AVFoundation

class GameMechanics {
    private var backgroundMusic: SKAudioNode?

    func setupBackgroundMusic(in scene: SKScene, filename: String = "FunnyCocktail", fileExtension: String = "mp3") {
        if let musicURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic?.autoplayLooped = true
            if let musicNode = backgroundMusic {
                scene.addChild(musicNode)
            }
        }
    }

    func pauseMusic() {
        backgroundMusic?.run(SKAction.pause())
    }

    func resumeMusic() {
        backgroundMusic?.run(SKAction.play())
    }

    func stopMusic() {
        backgroundMusic?.removeFromParent()
    }
}

