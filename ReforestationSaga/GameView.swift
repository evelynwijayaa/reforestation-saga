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
    @State private var showAlert = false
    @State private var scene: GameScene?
    @State var sceneID = UUID()
    @State private var isMuted: Bool = false
    @State private var currentLevel: Int = 1
    @State private var highestLevel: Int = 3
    @State private var treesRemaining: Int = 3
    @State private var showLevelClearPopup = false
    @State private var showMissionCompletePopup = false
    
    func setupScene(treesNeeded: Int) {
            let newScene = GameScene(size: CGSize(width: 400, height: 800))
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showAlert = true
            }
        newScene.onTreeHit = {
            treesRemaining -= 1
            if treesRemaining <= 0 {
                if currentLevel < highestLevel {
                    showLevelClearPopup = true

                    // Setelah popup muncul 2 detik, lanjut ke level berikutnya
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showLevelClearPopup = false
                        currentLevel += 1
                        let newTrees = (currentLevel == 2) ? 5 : 3
                        setupScene(treesNeeded: newTrees)
                    }
                } else {
                    // Munculkan Mission Complete tanpa delay
                    showMissionCompletePopup = true
                }
            }
        }

            newScene.configureLevel(treesNeeded: treesNeeded)
        self.treesRemaining = treesNeeded
        self.scene = newScene
            self.sceneID = UUID()
        }


    var body: some View {
        ZStack {

            CameraViewVision(eyeBlinkDetector: detector)
                .edgesIgnoringSafeArea(.all)
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            //            if let scene = scene {
            //                SpriteView(scene: scene, options: [.allowsTransparency])
            //                    .frame(width: 300, height: 600)
            //                    .ignoresSafeArea()
//            }
            //update eve
            SpriteView(scene: scene ?? GameScene(size: CGSize(width: 400, height: 800)), options: [.allowsTransparency])
                .frame(width: 300, height: 600)
                .id(sceneID) // ini kuncinya!
                .ignoresSafeArea()
            //notes: ini masi berantakan banget, harusnya ga pake vstack kaya gini
            VStack {
                HStack {
                    // Kiri Atas
                    BarView(treesRemaining: treesRemaining)
                    
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

            if showMissionCompletePopup {
                VStack {
                    PopUpMission {
                        // Next mission button action
                        currentLevel += 1
                        setupScene(treesNeeded: 3)
                        showMissionCompletePopup = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.black.opacity(0.5))
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showLevelClearPopup)
        .animation(.easeInOut(duration: 0.2), value: showMissionCompletePopup)

        
        .onAppear {
            //            detector.startCamera()
            let newScene = GameScene(size: CGSize(width: 400, height: 800))
            newScene.scaleMode = .resizeFill
            newScene.onFailZoneHit = {
                showAlert = true
            }
            self.scene = newScene
            setupScene(treesNeeded: 3)
        }
        // 🔥 Detect change and trigger function
        .onChange(of: detector.blinkCount) {
            scene?.shootNeedle()
        }
        .alert("Mission Failed!", isPresented: $showAlert) {
            Button("Try Again", role: .cancel) {}
        } message: {
            Text("Jarum mengenai zona terlarang.")
        }
    }
}

#Preview {
    GameView()
        .environmentObject(EyeBlinkDetectorVision())
}
