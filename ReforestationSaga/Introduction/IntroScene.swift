//
//  IntroScene.swift
//  ReforestationSaga
//
//  Created by Gibran Shevaldo on 14/06/25.
//

import SpriteKit
import SwiftUI
import AudioToolbox

class IntroScene: SKScene {
    private var missionPanel: SKSpriteNode!
    private var startButton: SKSpriteNode!
    var onStartMission: (() -> Void)?
    let mechanics = GameMechanics()
    
    
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
        
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupMissionPanel()
    }
    
    private func setupMissionPanel() {
        // Main mission panel
        missionPanel = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width - 40, height: 400)) //Index Blurring
        missionPanel.size = CGSize(width: size.width*2, height: size.height)
        missionPanel.position = CGPoint(x: size.width/2, y: size.height / 2)
        missionPanel.zPosition = 5
        addChild(missionPanel)
        
        setupMissionContent()
    }
    
    private func setupMissionContent() {
        // Mission Title
        let missionTitle = SKLabelNode(text: "Mission 001")
        missionTitle.fontName = "Gugi"
        missionTitle.fontSize = 17
        missionTitle.fontColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
        missionTitle.position = CGPoint(x: 0, y: 243)
        missionPanel.addChild(missionTitle)
        
        // Mission Description
        setupMissionDescription()
        
        // Instructions
        setupInstructions()
        
        // Eye symbols
        setupEyeSymbols()
    }
    
    private func setupMissionDescription() {
        let descriptionLines = [
            "Target Planet: Druvia.",
            "",
            "Druvia has breathable air and stable",
            "gravity, but its atmosphere is loaded with",
            "carbon-like compounds called \"Xarbon\"",
            "that are overheating the planet.",
            "",
            "Your objective: Plant \"Thryl Trees\" as",
            "their roots dig deep to absorb Xarbon, and",
            "their canopy releases cooling vapors that",
            "reflect excess solar radiation"
        ]
        
        for (index, line) in descriptionLines.enumerated() {
            let label = SKLabelNode(text: line)
            label.fontName = "Genos"
            label.fontSize = 17
            label.fontColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
            label.position = CGPoint(x: 0, y: 195 - CGFloat(index * 20))
            missionPanel.addChild(label)
        }
    }
    
    private func setupInstructions() {
        
        let instructionLines = [
            "What you should do:",
            "Every blink launches a Thryl Tree.",
            "Every tree absorbs Xarbon through",
            "their roots.",
            "",
            "The fate of Earth lies in your vision."
        ]
        
        for (index, line) in instructionLines.enumerated() {
            if !line.isEmpty {
                let label = SKLabelNode(text: line)
                label.fontName = "Genos"
                label.fontSize = 17
                label.fontColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
                label.position = CGPoint(x: 0, y: -65 - CGFloat(index * 18))
                missionPanel.addChild(label)
            }
        }
    }
    
    private func setupEyeSymbols() {
        // Create eye symbols
        let eye1 = createEyeSymbol()
        eye1.position = CGPoint(x: -30, y: -185)
        missionPanel.addChild(eye1)
        
        let eye2 = createEyeSymbol()
        eye2.position = CGPoint(x: 30, y: -185)
        missionPanel.addChild(eye2)
        
        // Animate eyes blinking
        animateEyes([eye1, eye2])
    }
    
    private func createEyeSymbol() -> SKNode {
        let eyeContainer = SKNode()
        
        // Eye outline
        let eyeOutline = SKShapeNode(ellipseOf: CGSize(width: 40, height: 25))
        eyeOutline.strokeColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
        eyeOutline.lineWidth = 2
        eyeOutline.fillColor = .clear
        eyeContainer.addChild(eyeOutline)
        
        // Pupil
        let pupil = SKSpriteNode(color: SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0), size: CGSize(width: 12, height: 12))
        pupil.name = "pupil"
        eyeContainer.addChild(pupil)
        
        return eyeContainer
    }
    
    private func animateEyes(_ eyes: [SKNode]) {
        for eye in eyes {
            let blink = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.scaleY(to: 0.1, duration: 0.1),
                SKAction.scaleY(to: 1.0, duration: 0.1)
            ])
            let blinkForever = SKAction.repeatForever(blink)
            eye.run(blinkForever)
        }
    }
}
