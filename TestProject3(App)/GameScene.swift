//
//  GameScene.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import SwiftUI
import AudioToolbox

class GameScene: SKScene {
    let circle = SKSpriteNode(imageNamed: "bumi")
    let needleContainer = SKNode()
    var onFailZoneHit: (() -> Void)? // Closure untuk trigger alert dari SwiftUI
    let mechanics = GameMechanics()

    func triggerAction(_ state: String) {
        if state == "Blink detected" {
            shootNeedle()
        }
    }
    
    func pauseMusic() {
        mechanics.pauseMusic()
    }
    
    func resumeMusic() {
        mechanics.resumeMusic()
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        view.allowsTransparency = true
        mechanics.setupBackgroundMusic(in: self)

        circle.size = CGSize(width: 160, height: 160)
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(circle)

        // Tambahkan needle container ke dalam lingkaran
        circle.addChild(needleContainer)
        
        let failZone = SKShapeNode(rectOf: CGSize(width: 110, height: 40))
//        failZone.fillColor = .red.withAlphaComponent(0.3) // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.position = CGPoint(x: -10, y: 80) // relatif terhadap center circle
        failZone.name = "failZone"
        circle.addChild(failZone)

        // Animasi rotasi lingkaran
        let rotate = SKAction.rotate(byAngle: .pi, duration: 2)
        let forever = SKAction.repeatForever(rotate)
        circle.run(forever)
    }
    
    func resetNeedles() {
        needleContainer.removeAllChildren()
    }

    func shootNeedle() {
        let needle = SKSpriteNode(imageNamed: "pohon")
        let needleLength: CGFloat = 40

        needle.size = CGSize(width: 20, height: needleLength)

        //        let needle = SKSpriteNode(color: .black, size: CGSize(width: 4, height: needleLength))

        // Posisi awal jarum (di atas lingkaran)
        let startY = circle.position.y + 300
        needle.position = CGPoint(x: circle.position.x, y: startY)
        needle.zRotation = 0
        addChild(needle)

        // Target: titik di permukaan luar lingkaran bagian atas
        let circleRadius: CGFloat = 80
        let targetPoint = CGPoint(
            x: circle.position.x,
            y: circle.position.y + circleRadius + needleLength / 2
        )

        let move = SKAction.move(to: targetPoint, duration: 0.3)

        let stickToCircle = SKAction.run {
            needle.removeAllActions()

            // Ubah posisi relatif ke circle
            let relativePosition = self.convert(
                needle.position,
                to: self.needleContainer
            )

            // Cek apakah masuk area gagal
            if let failZone = self.circle.childNode(withName: "failZone"),
               failZone.contains(relativePosition) {
                needle.removeFromParent()
                self.resetNeedles()
                
                // Trigger alert
                needle.removeAllChildren()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.onFailZoneHit?()
                return
            }
            
            needle.removeFromParent()
            needle.position = relativePosition

            // Koreksi rotasi agar tetap tegak
            needle.zRotation = -self.circle.zRotation

            self.needleContainer.addChild(needle)
        }

        let sequence = SKAction.sequence([move, stickToCircle])
        needle.run(sequence)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shootNeedle()
    }
}

#Preview {
    GameView()
}
