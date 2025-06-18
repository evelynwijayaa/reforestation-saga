//
//  GameScene.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import AudioToolbox
import SpriteKit
import SwiftUI

class GameScene: SKScene {
    let circle = SKSpriteNode(imageNamed: "bumi")
    let needleContainer = SKNode()
    var onFailZoneHit: (() -> Void)?  // Closure untuk trigger alert dari SwiftUI

    //tambahan eve
    var onTreeHit: (() -> Void)?

    private var treesShot = 0
    private var treesTarget = 3  // default level 1
    func configureLevel(
        treesNeeded: Int,
        rotationDuration: Double,
        rotateLeft: Bool
    ) {
        treesShot = 0
        treesTarget = treesNeeded
        resetNeedles()

        circle.removeAllActions()

        let angle: CGFloat = rotateLeft ? -.pi : .pi
        let rotate = SKAction.rotate(byAngle: angle, duration: rotationDuration)
        let forever = SKAction.repeatForever(rotate)
        circle.run(forever)
    }
    var remainingTrees: Int {
        return max(treesTarget - treesShot, 0)
    }

    func triggerAction(_ state: String) {
        if state == "Blink detected" {
            shootNeedle()
        }
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        view.allowsTransparency = true

        circle.size = CGSize(width: 400, height: 400)
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(circle)

        // Tambahkan needle container ke dalam lingkaran
        circle.addChild(needleContainer)

        setForbiddenArea()
    }

    func setForbiddenArea() {
        var failZone = SKShapeNode(rectOf: CGSize(width: 200, height: 110))
        //        failZone.fillColor = .red.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.position = CGPoint(x: 100, y: 22)  // relatif terhadap center circle
        failZone.name = "failZone-1"
        circle.addChild(failZone)

        failZone = SKShapeNode(rectOf: CGSize(width: 200, height: 150))
        //        failZone.fillColor = .red.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.position = CGPoint(x: -20, y: -120)  // relatif terhadap center circle
        failZone.name = "failZone-2"
        circle.addChild(failZone)

        failZone = SKShapeNode(rectOf: CGSize(width: 30, height: 100))
        //        failZone.fillColor = .red.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.zRotation = 45
        failZone.position = CGPoint(x: 150, y: -80)  // relatif terhadap center circle
        failZone.name = "failZone-3"
        circle.addChild(failZone)

        failZone = SKShapeNode(rectOf: CGSize(width: 35, height: 100))
        //        failZone.fillColor = .red.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.zRotation = 1
        failZone.position = CGPoint(x: -130, y: 70)  // relatif terhadap center circle
        failZone.name = "failZone-4"
        circle.addChild(failZone)
    }

    func resetNeedles() {
        needleContainer.removeAllChildren()
    }

    func shootNeedle() {
        GameMusicManager.shared.playSoundEffect(filename: "TreeSFX")
        guard remainingTrees > 0 else { return }

        let needle = SKSpriteNode(imageNamed: "pohon")
        let needleLength: CGFloat = 70

        needle.size = CGSize(width: 30, height: needleLength)

        //        let needle = SKSpriteNode(color: .black, size: CGSize(width: 4, height: needleLength))

        // Posisi awal jarum (di atas lingkaran)
        let startY = circle.position.y + 300
        needle.position = CGPoint(x: circle.position.x, y: startY)
        needle.zRotation = 0
        addChild(needle)

        // Target: titik di permukaan luar lingkaran bagian atas
        let circleRadius: CGFloat = 118
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
            let failZoneNames = [
                "failZone-1", "failZone-2", "failZone-3", "failZone-4",
            ]

            for zoneName in failZoneNames {
                if let failZone = self.circle.childNode(withName: zoneName),
                    failZone.contains(relativePosition)
                {

                    needle.removeFromParent()
                    self.resetNeedles()

                    // Trigger alert & efek
                    needle.removeAllChildren()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.onFailZoneHit?()
                    return
                }
            }

            // Cek bentrok dengan pohon yang sudah tertempel
            for child in self.needleContainer.children {
                if child.name == "treeZone", child.contains(relativePosition) {
                    needle.removeFromParent()
                    self.resetNeedles()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.onFailZoneHit?()
                    return
                }
            }

            needle.removeFromParent()
            needle.position = relativePosition

            // Koreksi rotasi agar tetap tegak
            needle.zRotation = -self.circle.zRotation
            needle.name = "treeZone"

            self.needleContainer.addChild(needle)

            //tambahan eve
            self.treesShot += 1
            self.onTreeHit?()
        }

        let sequence = SKAction.sequence([move, stickToCircle])
        needle.run(sequence)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        shootNeedle()
    }

}

#Preview {
    GameView.initForPreview()
        .environmentObject(GameData())
        .environmentObject(EyeBlinkDetectorVision())
}
