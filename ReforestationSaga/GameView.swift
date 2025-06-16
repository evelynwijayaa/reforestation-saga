//
//  GameView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    @EnvironmentObject var detector: EyeBlinkDetectorVision
    @State private var showMissionFailedPopup = false
    @State private var scene: GameScene?
    @State var sceneID = UUID()
    @State private var isMuted: Bool = false
    @State private var currentLevel: Int = 1
    @State private var highestLevel: Int = UserDefaults.standard.savedHighestLevel
    @State private var treesRemaining: Int = 3
    @State private var showLevelClearPopup = false
    @State private var treesNeeded: Int = 3
    
    func setupScene() {
        let newTrees = treesForLevel(currentLevel)
        self.treesNeeded = newTrees
        
        let newScene = GameScene(size: CGSize(width: 400, height: 800))
        newScene.scaleMode = .resizeFill
        newScene.onFailZoneHit = {
            showMissionFailedPopup = true
        }
        newScene.onTreeHit = {
            treesRemaining -= 1
            if treesRemaining <= 0 {
                    showLevelClearPopup = true

                    // Setelah popup muncul 1.2 detik, lanjut ke level berikutnya
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showLevelClearPopup = false
                        currentLevel += 1
                        
                        if currentLevel - 1 > highestLevel {
                                highestLevel = currentLevel - 1
                                UserDefaults.standard.savedHighestLevel = highestLevel
                            }
                        setupScene()
                }
            }
        }
        
        let rotationDuration: Double
        let rotateLeft: Bool
        
        if currentLevel <= 3 {
                rotationDuration = 2.0
                rotateLeft = false
            } else {
                // Level 4 dan seterusnya random
                rotationDuration = Double.random(in: 1.0...3.5)
                rotateLeft = Bool.random()
            }

        newScene.configureLevel(
            treesNeeded: treesNeeded,
            rotationDuration: rotationDuration,
            rotateLeft: rotateLeft
        )
        
        self.treesRemaining = treesNeeded
        self.scene = newScene
        self.sceneID = UUID()
        resumeGame()
    }
    
    func pauseGame() {
        scene?.isPaused = true
    }

    func resumeGame() {
        scene?.isPaused = false
    }

    
    var body: some View {
        ZStack {

            CameraViewVision(eyeBlinkDetector: detector)
                .edgesIgnoringSafeArea(.all)
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            SpriteView(scene: scene ?? GameScene(size: CGSize(width: 400, height: 800)), options: [.allowsTransparency])
                .frame(width: 300, height: 600)
                .id(sceneID) // ini kuncinya!
                .ignoresSafeArea()
            VStack {
                HStack {
                    // Kiri Atas
                    BarView(treesRemaining: treesRemaining, totalPollution: treesNeeded)
                    
                    Spacer()
                    
                    // Kanan Atas
                    LevelSoundView(
                        isMuted: $isMuted,
                        currentLevel: currentLevel,
                        highestLevel: highestLevel,
                        scene: scene
                    )
                    .offset(y: 8)
                    Button {
                        isMuted.toggle()
                        if isMuted {
                            scene?.pauseMusic()
                        } else {
                            scene?.resumeMusic()
                        }
                    } label: {}
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            if showLevelClearPopup {
                LevelCompletePopUp(level: currentLevel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black.opacity(0.5))
                    .transition(.scale)
                    .zIndex(1)
            }
            
            if showMissionFailedPopup {
                MissionFailedPopUp(highestLevel: $highestLevel, currentLevel: $currentLevel, isNewHighScore: currentLevel - 1 >= highestLevel, onNextMission: {
                        currentLevel = 1
                        highestLevel = UserDefaults.standard.savedHighestLevel
                        showMissionFailedPopup = false
                        setupScene()
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .transition(.scale)
                .zIndex(2)
            }
        }
        
        //buat tes preview
#if DEBUG
    .onTapGesture {
        scene?.shootNeedle()
    }
#endif

    .animation(.easeInOut(duration: 0.3), value: showMissionFailedPopup)
    .animation(.easeInOut(duration: 0.3), value: showLevelClearPopup)
        
        .onAppear {
            //            detector.startCamera()
            let newScene = GameScene(size: CGSize(width: 400, height: 800))
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showMissionFailedPopup = true
            }
            self.scene = newScene
            setupScene()
        }
        .onChange(of: showMissionFailedPopup) { newValue in
            if newValue {
                pauseGame()
            } else {
                resumeGame()
            }
        }
        .onChange(of: showLevelClearPopup) { newValue in
            if newValue {
                pauseGame()
            } else {
                resumeGame()
            }
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.blinkCount) {
            if !showMissionFailedPopup && !showLevelClearPopup {
                scene?.shootNeedle()
            }
        }
    }
}

func treesForLevel(_ level: Int) -> Int {
    let base = 3
    let cycle = (level - 1) / 5
    let positionInCycle = (level - 1) % 5
    return base + cycle + positionInCycle
}


extension UserDefaults {
    private enum Keys {
        static let highestLevel = "highestLevel"
    }

    var savedHighestLevel: Int {
        get { integer(forKey: Keys.highestLevel) }
        set { set(newValue, forKey: Keys.highestLevel) }
    }
}

#Preview {
    GameView.initForPreview()
        .environmentObject(EyeBlinkDetectorVision())
}

extension GameView {
    static func initForPreview() -> GameView {
        var view = GameView()
        let scene = GameScene(size: CGSize(width: 400, height: 800))
        let treesNeeded = 3
        let rotationDuration = Double.random(in: 1.5...3.5)
        let rotateLeft = Bool.random()
        scene.configureLevel(treesNeeded: treesNeeded, rotationDuration: rotationDuration, rotateLeft: rotateLeft)
        view._scene = State(initialValue: scene)
        return view
    }
}
