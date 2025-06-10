//
//  GameScene.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//


import SpriteKit

class GameScene: SKScene {
    let circle = SKSpriteNode(imageNamed: "bumi")
    let needleContainer = SKNode()

    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        circle.size = CGSize(width: 160, height: 160)
        circle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(circle)
        
        // Tambahkan needle container ke dalam lingkaran
        circle.addChild(needleContainer)

        // Animasi rotasi lingkaran
        let rotate = SKAction.rotate(byAngle: .pi, duration: 1)
        let forever = SKAction.repeatForever(rotate)
        circle.run(forever)
    }
    
    func shootNeedle() {
        let needle = SKSpriteNode(imageNamed: "pohon")
        let needleLength: CGFloat = 40
        
        needle.size = CGSize(width: 20, height: needleLength)
        
        
//        let needle = SKSpriteNode(color: .black, size: CGSize(width: 4, height: needleLength))
        
        // Posisi awal jarum (di atas lingkaran)
        let startY = circle.position.y + 150
        needle.position = CGPoint(x: circle.position.x, y: startY)
        needle.zRotation = 0
        addChild(needle)
        
        // Target: titik di permukaan luar lingkaran bagian atas
        let circleRadius: CGFloat = 80
        let targetPoint = CGPoint(x: circle.position.x, y: circle.position.y + circleRadius + needleLength / 2)
        
        let move = SKAction.move(to: targetPoint, duration: 0.2)
        
        let stickToCircle = SKAction.run {
            needle.removeAllActions()

            // Ubah posisi relatif ke circle
            let relativePosition = self.convert(needle.position, to: self.needleContainer)
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
