//
//  MissionIntroView.swift
//  ReforestationSaga
//
//  Created by Gibran Shevaldo on 14/06/25.
//

import SpriteKit
import SwiftUI

struct IntroView: View {
    @State private var showAlert = false
    @State private var scene: IntroScene?
    @State private var isMuted: Bool = false
    @State private var navToGame = false
    @State private var glowOpacity: Double = 0.7
    @EnvironmentObject var gameData: GameData
    @State private var currentLevel: Int = 1
    var gamescene: GameScene?

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            Image("introBorder")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 450)
                .padding(.bottom, 60)

            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: 300, height: 600)
                    .ignoresSafeArea()
            }

            VStack {
                VStack {
                    HStack {
                        Spacer()

                        // Kanan Atas
                        LevelSoundView(
                            isMuted: $isMuted,
                            currentLevel: currentLevel,
                            scene: gamescene
                        )
                        .offset(y: 4)
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
                }
                .padding(.top, -5)

                Spacer()

                NavigationLink(
                    destination: GameView().navigationBarHidden(true),
                    isActive: $navToGame
                ) {
                }
                .hidden()

                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(
                        style: .medium)
                    impactFeedback.impactOccurred()

                    navToGame = true
                }) {
                    Image("startMission")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                .buttonStyle(PlainButtonStyle())

                // Glow animation effect
                .shadow(
                    color: Color(red: 0.94, green: 0.84, blue: 0.65)
                        .opacity(glowOpacity),
                    radius: 20,
                    x: 0,
                    y: 0
                )
                .onAppear {
                    startGlowAnimation()
                }
            }
            .padding(.horizontal, 25)

            //Atas
            Image("Separator")
                .resizable()
                .scaledToFit()
                .frame(width: 305, height: 200)
                .padding(.top, -300)

            //Bawah
            Image("Separator")
                .resizable()
                .scaledToFit()
                .frame(width: 305, height: 200)
                .padding(.top, 25)
        }
        .onAppear {
            setupScene()
        }
        .navigationBarBackButtonHidden(true)

    }

    private func setupScene() {
        let newScene = IntroScene()
        newScene.scaleMode = .resizeFill
        newScene.onStartMission = {
            navToGame = true
        }

        self.scene = newScene
    }

    private func startGlowAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            glowOpacity = glowOpacity == 0.7 ? 1.0 : 0.7
        }
    }
}

#Preview {
    IntroView()
        .environmentObject(GameData())
}
