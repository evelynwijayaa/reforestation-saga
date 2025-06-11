//
//  GameScene.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let needle: UInt32 = 0b1
        static let tanah: UInt32 = 0b10
        static let laut: UInt32 = 0b100
    }

    let circle = SKNode()
    let laut = SKSpriteNode(imageNamed: "bumilaut")
    let tanah = SKSpriteNode(imageNamed: "bumitanah")
    let needleContainer = SKNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero

        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(circle)

        // Setup laut
        laut.size = CGSize(width: 160, height: 160)
        laut.position = .zero
        circle.addChild(laut)

        // Setup tanah
        tanah.size = laut.size
        tanah.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tanah.position = .zero
        circle.addChild(tanah)

        // Rotasi
        let rotate = SKAction.rotate(byAngle: -.pi, duration: 2)
        circle.run(.repeatForever(rotate))

        // Container untuk pisau
        circle.addChild(needleContainer)

        // Add invisible physics zones
        addPhysicsZones()
    }

    func addPhysicsZones() {
        // Laut (besar) - game over
        let lautArea = SKShapeNode(circleOfRadius: 80)
        lautArea.strokeColor = .clear
        lautArea.fillColor = .blue
        lautArea.alpha = 0.01
        lautArea.position = circle.position
        lautArea.physicsBody = SKPhysicsBody(circleOfRadius: 80)
        lautArea.physicsBody?.isDynamic = false
        lautArea.physicsBody?.categoryBitMask = PhysicsCategory.laut
        lautArea.physicsBody?.contactTestBitMask = PhysicsCategory.needle
        addChild(lautArea)

        // Tanah (lebih kecil) - sukses
        let tanahArea = SKShapeNode(circleOfRadius: 80)
        tanahArea.strokeColor = .clear
        tanahArea.fillColor = .green
        tanahArea.alpha = 0.01
        tanahArea.position = circle.position
        tanahArea.physicsBody = SKPhysicsBody(circleOfRadius: 80)
        tanahArea.physicsBody?.isDynamic = false
        tanahArea.physicsBody?.categoryBitMask = PhysicsCategory.tanah
        tanahArea.physicsBody?.contactTestBitMask = PhysicsCategory.needle
        addChild(tanahArea)
    }

    func shootNeedle() {
        let needle = SKSpriteNode(imageNamed: "pohon")
        let needleLength: CGFloat = 40
        needle.size = CGSize(width: 20, height: needleLength)

        let startY = circle.position.y + 200
        needle.position = CGPoint(x: circle.position.x, y: startY)
        needle.zRotation = 0
        needle.name = "needle"

        // Add physics body
        needle.physicsBody = SKPhysicsBody(rectangleOf: needle.size)
        needle.physicsBody?.isDynamic = true
        needle.physicsBody?.categoryBitMask = PhysicsCategory.needle
        needle.physicsBody?.contactTestBitMask = PhysicsCategory.tanah | PhysicsCategory.laut
        needle.physicsBody?.collisionBitMask = PhysicsCategory.none

        addChild(needle)

        // Move ke tengah
        let move = SKAction.move(to: CGPoint(x: circle.position.x, y: circle.position.y), duration: 0.4)
        needle.run(move)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shootNeedle()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let (first, second) = (contact.bodyA.node, contact.bodyB.node)

        guard let nodeA = first, let nodeB = second else { return }

        let needle = (nodeA.name == "needle") ? nodeA : nodeB
        let other = (needle === nodeA) ? nodeB : nodeA

        if other.physicsBody?.categoryBitMask == PhysicsCategory.tanah {
            // Nancep di tanah
            let localPos = convert(needle.position, to: needleContainer)
            needle.removeFromParent()
            needle.position = localPos
            needle.zRotation = -circle.zRotation
            needle.physicsBody = nil
            needleContainer.addChild(needle)
        } else if other.physicsBody?.categoryBitMask == PhysicsCategory.laut {
            // Kena laut
            needle.removeFromParent()
            showLoseAlert()
        }
    }

    func showLoseAlert() {
        if let view = self.view, let vc = view.window?.rootViewController {
            let alert = UIAlertController(title: "You lose", message: "Kena laut!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
        }
    }
}
