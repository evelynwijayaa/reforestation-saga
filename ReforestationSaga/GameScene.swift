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
    let circle = SKSpriteNode(imageNamed: "buminew")
    let needleContainer = SKNode()
    var onFailZoneHit: (() -> Void)?  // Closure untuk trigger alert dari SwiftUI
    var isFail: Bool = false
    //tambahan eve
    var onTreeHit: (() -> Void)?

    private var treesShot = 0
    private var treesTarget = 3  // default level 1
    private var isGameActive = true
    func configureLevel(
        treesNeeded: Int,
        rotationDuration: Double,
        rotateLeft: Bool
    ) {
        isGameActive = true
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

        circle.size = CGSize(width: 590, height: 590)
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2.8)
        addChild(circle)

        // Tambahkan needle container ke dalam lingkaran
        circle.addChild(needleContainer)

        setForbiddenArea()
    }

    private func arcPath(
        radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat
    ) -> UIBezierPath {
        let arcPath = UIBezierPath()
        arcPath.move(to: .zero)
        arcPath.addArc(
            withCenter: .zero, radius: radius, startAngle: startAngle,
            endAngle: endAngle, clockwise: true)
        arcPath.close()

        return arcPath
    }

    func setForbiddenArea() {

        //YANG PERTAMA

        var failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 6, endAngle: 6.97).cgPath)

        //        var failZone = SKShapeNode(rectOf: CGSize(width: 200, height: 105))
        //        failZone.fillColor = .red.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.position = CGPoint(x: 0, y: 0)  // relatif terhadap center circle
        failZone.name = "failZone-1"
        circle.addChild(failZone)

        //YANG KEDUA
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 3.96, endAngle: 5.30).cgPath)

        //        failZone = SKShapeNode(rectOf: CGSize(width: 143, height: 150))
        //                failZone.fillColor = .gold.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.name = "failZone-2"
        circle.addChild(failZone)

        //YANG KETIGA
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 4.73, endAngle: 4.88).cgPath)
        //                failZone.fillColor = .blue.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.zRotation = 45
        failZone.name = "failZone-3"
        circle.addChild(failZone)

        //YANG KEEMPAT
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 1.62, endAngle: 1.76).cgPath)
        //        failZone.fillColor = .purple.withAlphaComponent(0.3)  // untuk debug, bisa diset ke 0 nanti
        failZone.strokeColor = .clear
        failZone.zRotation = 1
        failZone.name = "failZone-4"
        circle.addChild(failZone)
    }

    func resetNeedles() {
        needleContainer.removeAllChildren()
    }

    func shootNeedle() {
        guard isGameActive else { return }
        guard remainingTrees > 0 else { return }
        guard isFail == false else { return }
        GameMusicManager.shared.playSoundEffect(filename: "TreeSFX")
        let needle = SKSpriteNode(imageNamed: "pohon")
        let needleLength: CGFloat = 70

        needle.size = CGSize(width: 30, height: needleLength)

        //                let needle = SKSpriteNode(color: .white, size: CGSize(width: 4, height: needleLength))

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

        let move = SKAction.move(to: targetPoint, duration: 0.2)

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
                    //                    needle.removeFromParent()
                    //                    self.resetNeedles()

                    // Trigger alert & efek
                    needle.removeAllChildren()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.isFail = true
                    self.onFailZoneHit?()
                    self.isGameActive = false
                    return
                }
            }

            // Cek bentrok dengan pohon yang sudah tertempel
            for child in self.needleContainer.children {
                if child.name == "treeZone" {
                    let distance = hypot(
                        child.position.x - relativePosition.x,
                        child.position.y - relativePosition.y
                    )

                    let minAllowedDistance: CGFloat = 30  // Sesuaikan dengan ukuran pohon kamu

                    if distance < minAllowedDistance {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        self.isFail = true
                        self.onFailZoneHit?()
                        return
                    }
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

            if self.treesShot >= self.treesTarget {
                self.isGameActive = false  // Matikan input, tunggu level complete handler
            }
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
