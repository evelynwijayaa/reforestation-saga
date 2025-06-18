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
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        view.allowsTransparency = true
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupMissionPanel()
    }
    
    private func setupMissionPanel() {
        missionPanel = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width - 40, height: 400)) // Background blurring index
        missionPanel.size = CGSize(width: size.width*2, height: size.height)
        missionPanel.position = CGPoint(x: size.width/2, y: size.height / 2)
        missionPanel.zPosition = 5
        addChild(missionPanel)
        
        setupMissionContent()
    }
    
    private func setupMissionContent() {
        let missionTitle = SKLabelNode(text: "Your Mission")
        missionTitle.fontName = "Gugi"
        missionTitle.fontSize = 17
        missionTitle.fontColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
        missionTitle.position = CGPoint(x: 0, y: 220)
        missionPanel.addChild(missionTitle)
        
        setupMissionDescription()
        
        setupInstructions()
        
        setupEyeSymbols()
    }
    
    private func setupMissionDescription() {
        let descriptionLines = [
            "Target Planet: Earth.",                        // Index 0 - BOLD 1 baris
            "",                                             // Index 1
            "Atmospheric carbon levels have",               // Index 2
            "surged. Temperatures are rising. Life ",       // Index 3
            "systems are destabilizing.",                   // Index 4
            "",                                             // Index 5
            "Your objective: Deploy carbon-",               // Index 6 - BOLD (hanya string "Your objective")
            "capture units via orbital tree pods to",       // Index 7
            "help reforest high-emission zones."            // Index 8
        ]
        
        let partialBoldWords: [Int: [String]] = [
//            4: ["Xarbon"],
//            5: ["overheating the planet"],
            6: ["Your objective"]
        ]
        
        let fullLineBoldIndices: Set<Int> = [0]
        
        for (index, line) in descriptionLines.enumerated() {
            if line.isEmpty {
                continue
            }
            
            let label = SKLabelNode()
            
            if let wordsToBold = partialBoldWords[index] {
                // NSMutableAttributedString untuk partial bold
                let attributedString = NSMutableAttributedString(
                    string: line,
                    attributes: [
                        .font: UIFont(name: "Genos", size: 17) ?? UIFont.systemFont(ofSize: 17),
                        .foregroundColor: UIColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
                    ]
                )
                
                for word in wordsToBold {
                    let range = (line as NSString).range(of: word)
                    if range.location != NSNotFound {
                        attributedString.addAttribute(
                            .font,
                            value: UIFont(name: "Genos-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
                            range: range
                        )
                    }
                }
                
                label.attributedText = attributedString
                
            } else { // Untuk baris yang seluruhnya bold atau normal
                let shouldBeBold = fullLineBoldIndices.contains(index)
                let fontName = shouldBeBold ? "Genos-Bold" : "Genos"
                
                label.fontName = fontName
                label.fontSize = 17
                label.fontColor = UIColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
                label.text = line
            }
            
            label.position = CGPoint(x: 0, y: 170 - CGFloat(index * 20))
            missionPanel.addChild(label)
        }
    }
    
    private func setupInstructions() {
        
        let instructionLines = [
            "What you should do:",
            "Every blink launches a tree. Every tree ",
            "draws down carbon.",
            "",
            "The fate of Earth lies in your vision."
        ]
        
        let boldIndices: Set<Int> = [0]
        
        for (index, line) in instructionLines.enumerated() {
            if line.isEmpty {
                continue
            }
            
            let label = SKLabelNode()
            
            let shouldBeBold = boldIndices.contains(index)
            
            let fontName = shouldBeBold ? "Genos-Bold" : "Genos"
            
            label.fontName = fontName
            label.fontSize = 17
            label.fontColor = UIColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
            label.text = line
            label.position = CGPoint(x: 0, y: -45 - CGFloat(index * 18))
            
            missionPanel.addChild(label)
        }
    }
    
    private func setupEyeSymbols() {
        let eye1 = createEyeSymbol()
        eye1.position = CGPoint(x: -30, y: -150)
        missionPanel.addChild(eye1)
        
        let eye2 = createEyeSymbol()
        eye2.position = CGPoint(x: 30, y: -150)
        missionPanel.addChild(eye2)
        
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
        let pupilSize: CGFloat = 14
        let pupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        pupil.fillColor = SKColor(red: 0.94, green: 0.84, blue: 0.65, alpha: 1.0)
        pupil.strokeColor = SKColor.clear
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
