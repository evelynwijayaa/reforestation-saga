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
    var onFailZoneHit: (() -> Void)?
    var onTreeZoneHit: (() -> Void)?
    var isFail: Bool = false
    var onTreeHit: (() -> Void)?
    private var treeIndicator: SKSpriteNode?
    private var treesShot = 0
    private var treesTarget = 3

    func configureLevel(
        treesNeeded: Int,
        rotationDuration: Double,
        rotateLeft: Bool
    ) {
        treesShot = 0
        treesTarget = treesNeeded
        resetNeedles()
        setupTreeIndicator()
        treeIndicator?.isHidden = false

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

        circle.addChild(needleContainer)

        setForbiddenArea()
        setupTreeIndicator()
    }

    private func setupTreeIndicator() {
        treeIndicator?.removeFromParent()

        // Create new tree indicator
        treeIndicator = SKSpriteNode(imageNamed: "pohonnew")
        guard let indicator = treeIndicator else { return }

        indicator.size = CGSize(width: 30, height: 70)

        let startY = circle.position.y + 300
        indicator.position = CGPoint(x: circle.position.x, y: startY)
        indicator.zRotation = 0
        indicator.alpha = 0.7
        indicator.name = "treeIndicator"

        addChild(indicator)

        let floatUp = SKAction.moveBy(x: 0, y: 10, duration: 1.0)
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)

        indicator.run(floatForever)
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

        failZone.strokeColor = .clear
        failZone.position = CGPoint(x: 0, y: 0)  // relatif terhadap center circle
        failZone.name = "failZone-1"
        circle.addChild(failZone)

        //YANG KEDUA
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 3.96, endAngle: 5.30).cgPath)

        failZone.strokeColor = .clear
        failZone.name = "failZone-2"
        circle.addChild(failZone)

        //YANG KETIGA
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 4.73, endAngle: 4.88).cgPath)

        failZone.strokeColor = .clear
        failZone.zRotation = 45
        failZone.name = "failZone-3"
        circle.addChild(failZone)

        //YANG KEEMPAT
        failZone = SKShapeNode(
            path: arcPath(radius: 300, startAngle: 1.62, endAngle: 1.76).cgPath)
        failZone.strokeColor = .clear
        failZone.zRotation = 1
        failZone.name = "failZone-4"
        circle.addChild(failZone)
    }

    func resetNeedles() {
        needleContainer.removeAllChildren()
    }

    func shootNeedle() {
        guard remainingTrees > 0 else { return }
        guard isFail == false else { return }
        GameMusicManager.shared.playSoundEffect(filename: "TreeSFX")
        let needle = SKSpriteNode(imageNamed: "pohonnew")
        treeIndicator?.isHidden = true
        let needleLength: CGFloat = 70

        needle.size = CGSize(width: 30, height: needleLength)

        // Posisi awal jarum (di atas lingkaran) - sama dengan indicator
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

        let move = SKAction.move(to: targetPoint, duration: 0.18)

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
                   let splash = SKSpriteNode(imageNamed: "splash")
                    splash.position = CGPoint(
                        x: needle.position.x,
                        y: needle.position.y - 15
                    )
                    splash.setScale(0.11)
                    self.addChild(splash)

                    // Trigger alert & efek
                    needle.removeAllChildren()
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.isFail = true
                    self.onFailZoneHit?()
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
                    let minAllowedDistance: CGFloat = 30
                    if distance < minAllowedDistance {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        let crash = SKSpriteNode(imageNamed: "crash")
                        crash.position = CGPoint(
                            x: needle.position.x + 10,
                            y: needle.position.y + 15
                        )
                        crash.setScale(0.12)
                        self.addChild(crash)
                        self.onTreeZoneHit?()
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
                // Jangan tampilkan indicator lagi karena sudah selesai
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    guard let indicator = self.treeIndicator else { return }

                    // Set posisi awal lebih tinggi
                    let normalY = self.circle.position.y + 300
                    let startY = normalY + 30  // Mulai dari 100 point lebih tinggi

                    indicator.position = CGPoint(
                        x: self.circle.position.x, y: startY)
                    indicator.alpha = 0  // Mulai transparan
                    indicator.isHidden = false

                    // Animasi turun ke posisi normal sambil fade in
                    let moveDown = SKAction.moveTo(y: normalY, duration: 0.1)
                    let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.1)  // Fade ke alpha normal (0.7)
                    let appearGroup = SKAction.group([moveDown, fadeIn])

                    // Setelah muncul, lanjutkan dengan animasi floating
                    let setupFloating = SKAction.run {
                        let floatUp = SKAction.moveBy(
                            x: 0, y: 10, duration: 1.0)
                        let floatDown = SKAction.moveBy(
                            x: 0, y: -10, duration: 1.0)
                        let floatSequence = SKAction.sequence([
                            floatUp, floatDown,
                        ])
                        let floatForever = SKAction.repeatForever(floatSequence)
                        indicator.run(floatForever, withKey: "floating")
                    }

                    let sequence = SKAction.sequence([
                        appearGroup, setupFloating,
                    ])
                    indicator.run(sequence)
                }
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
