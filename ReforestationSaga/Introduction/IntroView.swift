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

    var body: some View {
        ZStack {
            Image("background")
                .edgesIgnoringSafeArea(.all)

            Image("introBorder")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 450)
                .padding(.bottom, 0)

            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: 300, height: 600)
                    .ignoresSafeArea()
            }

            HStack {
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("Highest level: 0")
                            .font(Font.custom("Gugi", size: 14))
                            .foregroundColor(
                                Color(red: 0.94, green: 0.84, blue: 0.65)
                            )
                            .padding(.bottom, 9)
                            .padding(.horizontal, 25)
                    }
                    .padding(.top, 30)

                    HStack {
                        Spacer()
                        ZStack {
                            Image("box")
                                .resizable()
                                .frame(width: 120, height: 40)
                            Text("LEVEL 1")
                                .font(Font.custom("Gugi", size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundColor(
                                    Color(red: 0.94, green: 0.84, blue: 0.65)
                                )
                                .padding(.bottom, 9)
                        }
                    }
                    .padding(.horizontal, 20)

                    HStack {
                        Spacer()

                        Button {
                            isMuted.toggle()
                            if isMuted {
                                scene?.pauseMusic()
                            } else {
                                scene?.resumeMusic()
                            }
                        } label: {
                            Image(isMuted ? "sound-off" : "sound-on")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(.horizontal, 25)

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
                    .padding(.leading, 0)
                    .padding(.bottom, 20)
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
                .padding(.top, 20)
                .padding(.horizontal, 25)
            }

            //Atas
            Image("Separator")
                .resizable()
                .scaledToFit()
                .frame(width: 305, height: 200)
                .padding(.top, -270)

            //Bawah
            Image("Separator")
                .resizable()
                .scaledToFit()
                .frame(width: 305, height: 200)
                .padding(.top, 80)
        }
        .onAppear {
            setupScene()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func setupScene() {
        let newScene = IntroScene(size: CGSize(width: 400, height: 800))
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
}
