//
//  ReforestationSagaView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 11/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var scene: GameScene?
    @State private var isMuted: Bool = false
    @State private var navigateToGame = false
    @State private var QuestView = false
    @EnvironmentObject var gameData: GameData

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Latar belakang
                Image("background")
                    .ignoresSafeArea()

                HStack {
                    ZStack {
                        Image("box")
                            .resizable()
                            .frame(width: 140, height: 40)
                        Text("Highest Level: \(gameData.highestLevel)")
                            .font(Font.custom("Gugi", size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(
                                Color(red: 0.94, green: 0.84, blue: 0.65)
                            )
                            .padding(.bottom, 8)
                    }

                }
                .padding(.top, 58)
                
                Button {
                    isMuted.toggle()
                    if isMuted {
                        GameMusicManager.shared.pauseMusic()
                    } else {
                        GameMusicManager.shared.resumeMusic()
                    }
                } label: {
                    Image(isMuted ? "soundoff" : "sound")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                //                            .position(x: geometry.size.width * 0.10, y: 55)
                //                            .padding(.trailing, 120)
                .padding(.leading, 300)
                //                        }
                .padding(.top, 55)
                .zIndex(2)
                .buttonStyle(PlainButtonStyle())

                // Konten utama
                GeometryReader { geometry in
                    VStack {

                        ZStack {
                            Image("cahayaungu")
                                .resizable()
                                .scaledToFit()
                                .ignoresSafeArea()
                                .frame(width: 600, height: 600)
                                .offset(y: -20)
                                .zIndex(0)

                            Image("bumidisplay")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 267, height: 274)
                                .zIndex(1)
                        }
                        .frame(maxHeight: 274)
                        .padding(.top, 50)

                        if !QuestView {
                            // Judul Game
                            VStack {
                                Text("\n\nREFORESTATION\nSAGA")
                                    .font(Font.custom("Gugi", size: 32.28829))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(
                                        Color(
                                            red: 0.94, green: 0.84, blue: 0.65)
                                    )
                                    .shadow(
                                        color: .white.opacity(0.4), radius: 10)

                                Text("Tap to Play")
                                    .font(Font.custom("Electrolize", size: 17))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                                    .padding(.top, 20)
                                    .padding(.bottom, 70)
                            }
                            .padding(.top, 23)
//                                                        .background(Color.red.opacity(0.1))

                        } else {
                            ZStack {
                                Image("questbox")
                                    .resizable()
                                    .padding(.top, 120)
                                    .padding(.bottom, 30)
                                    .frame(width: 380, height: 380)

                                (Text("Welcome aboard, Cadet!\n\n ")
                                    .font(Font.custom("Gugi", size: 17))
                                    + Text("You’ve arrived at ").font(
                                        Font.custom("Genos", size: 17))
                                    + Text("Intergalactic Reforestation Unit")
                                    .font(Font.custom("Genos-bold", size: 17))
                                    + Text(
                                        ", stationed on the edge of the exosphere.\nWe aim to help planets in crisis, overheating, choking on carbon, and/or running out of time.\n\nBut before we brief you, "
                                    ).font(Font.custom("Genos", size: 17))
                                    + Text("we need to verify your identity")
                                    .font(Font.custom("Genos-bold", size: 17))
                                    + Text(
                                        ". Please align your face with the scanner."
                                    ).font(Font.custom("Genos", size: 17)))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(
                                        Color(
                                            red: 0.94, green: 0.84, blue: 0.65)
                                    )
                                    .frame(width: 350)
                                    .padding(.top, 80)


                                NavigationLink(destination: CameraCheckView()) {
                                    Image("verifybutton")
                                        .resizable()
                                        .frame(width: 95, height: 44)
                                        .padding(.top, 320)
                                        .padding(.leading, 240)
                                }
                            }
                            .padding(.top, -109)
                        }
                    }
                    .frame(width: geometry.size.width)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2)
                    .contentShape(Rectangle()) // Buat seluruh area bisa ditap
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                    QuestView = true
                                }
                        }
                }
            }
        }
        .onAppear() {
            GameMusicManager.shared.playMusic(filename: "IntroSpace")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(GameData())
}
