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
    @EnvironmentObject var gameData: GameData
    @State private var treesRemaining: Int = 3
    @State private var showLevelClearPopup = false
    @State private var treesNeeded: Int = 3
    @State private var hasSetupScene = false
    @State private var showInitialBlinkAlert: Bool = true
    @State private var hasPlantedFirstTree: Bool = false
    @State private var reason: String = "laut"

    //buat preview
    init() {
        _isMuted = State(initialValue: false)
        _currentLevel = State(initialValue: 1)
        _treesRemaining = State(initialValue: 3)
        _treesNeeded = State(initialValue: 3)
        _scene = State(initialValue: nil)
    }

    // Custom init untuk preview
    init(scene: GameScene?, currentLevel: Int, isMuted: Bool, treesRemaining: Int, treesNeeded: Int, showInitialBlinkAlert: Bool = true) {
        _scene = State(initialValue: scene)
        _currentLevel = State(initialValue: currentLevel)
        _isMuted = State(initialValue: isMuted)
        _treesRemaining = State(initialValue: treesRemaining)
        _treesNeeded = State(initialValue: treesNeeded)
        _showInitialBlinkAlert = State(initialValue: showInitialBlinkAlert)
    }

    func setupScene() {
        if let oldScene = scene {
            oldScene.removeAllActions()
            oldScene.removeAllChildren()
            oldScene.removeFromParent()
        }
        
        reason = "laut";
        let newTrees = treesForLevel(currentLevel)
        self.treesNeeded = newTrees
        let newScene = GameScene(size: UIScreen.main.bounds.size)
        newScene.scaleMode = .resizeFill
        newScene.onFailZoneHit = {
            showMissionFailedPopup = true
        }
        newScene.onTreeZoneHit = {
            reason = "pohon"
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

                    if currentLevel - 1 > gameData.highestLevel {
                        gameData.highestLevel = currentLevel - 1
                        UserDefaults.standard.savedHighestLevel =
                            gameData.highestLevel
                    }
                    setupScene()
                }
            }
        }

        let rotationDuration: Double
        let rotateLeft: Bool

        switch currentLevel {
        case 1...5:
            rotationDuration = 4
            rotateLeft = false
        case 6...10:
            rotationDuration = 3
            rotateLeft = Bool.random()
        default:
            rotationDuration = Double.random(in: 1.5...4)
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
            SpriteView(
                scene: scene
                    ?? GameScene(size: UIScreen.main.bounds.size),
                options: [.allowsTransparency]
            )
            .id(sceneID)  // ini kuncinya!
            .ignoresSafeArea()
            VStack {
                HStack {
                    // Kiri Atas
                    BarView(
                        treesRemaining: treesRemaining,
                        totalPollution: treesNeeded)

                    Spacer()

                    // Kanan Atas
                    LevelSoundView(
                        isMuted: $isMuted,
                        currentLevel: currentLevel,
                        scene: scene
                    )
                    .offset(y: 8)
                    Button {
                        isMuted.toggle()
                        if isMuted {
                            GameMusicManager.shared.pauseMusic()
                        } else {
                            GameMusicManager.shared.resumeMusic()
                        }
                    } label: {
                    }
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
                MissionFailedPopUp(
                    currentLevel: $currentLevel,
                    reason: $reason,
                    isNewHighScore: currentLevel - 1 >= gameData.highestLevel,
                    onNextMission: {
                        currentLevel = 1
                        gameData.highestLevel =
                            UserDefaults.standard.savedHighestLevel
                        showMissionFailedPopup = false
                        setupScene()
                        showInitialBlinkAlert = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .transition(.scale)
                .zIndex(2)
            }
            
            if showInitialBlinkAlert {
                BlinkAlert()
                    .transition(.opacity)
                    .zIndex(3)
                    .padding(.top,220)
            }
        }
        .navigationBarBackButtonHidden(true)

        //buat tes preview
#if DEBUG
        .onTapGesture {
            if showInitialBlinkAlert {
                showInitialBlinkAlert = false
                hasPlantedFirstTree = true
                if (treesRemaining > 0) {
                    scene?.shootNeedle()
                }
            } else {
                if (treesRemaining > 0) {
                    scene?.shootNeedle()
                }
            }
        }

#endif

        .animation(.easeInOut(duration: 0.3), value: showMissionFailedPopup)
        .animation(.easeInOut(duration: 0.3), value: showLevelClearPopup)
        .animation(.easeInOut(duration: 0.3), value: showInitialBlinkAlert)

        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            guard !hasSetupScene else { return }
            let newScene = GameScene(size: UIScreen.main.bounds.size)
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showMissionFailedPopup = true
            }
            self.scene = newScene

            setupScene()
            GameMusicManager.shared.stopMusic()
            GameMusicManager.shared.playMusic(filename: "GameEasy")
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false // aktifkan lagi kalau mau
        }
        .onChange(of: showMissionFailedPopup) { newValue in
            if newValue {
                pauseGame()
                GameMusicManager.shared.playSoundEffect(filename: "failed")
                GameMusicManager.shared.pauseMusic()
            } else {
                resumeGame()
                GameMusicManager.shared.resumeMusic()
            }
        }
        .onChange(of: showLevelClearPopup) { newValue in
            if newValue {
                pauseGame()
                GameMusicManager.shared.playSoundEffect(filename: "success")
            } else {
                resumeGame()
            }
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.blinkCount) {
            if showInitialBlinkAlert {
                showInitialBlinkAlert = false
                hasPlantedFirstTree = true
                if (treesRemaining > 0) {
                    scene?.shootNeedle()
                }
            } else if !showMissionFailedPopup && !showLevelClearPopup {
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
        .environmentObject(GameData())
        .environmentObject(EyeBlinkDetectorVision())
}

extension GameView {
    static func initForPreview() -> GameView {
        var view = GameView()
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.configureLevel(
            treesNeeded: 3, rotationDuration: 2.0, rotateLeft: false)

        // Gunakan Binding dengan .constant untuk State
        view = GameView(
            scene: scene,
            currentLevel: 1,
            isMuted: false,
            treesRemaining: 3,
            treesNeeded: 3,
            showInitialBlinkAlert: true
        )

        return view
    }
}
