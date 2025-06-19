//
//  PopUpMission.swift
//  ReforestationSaga
//
//  Created by Evelyn Wijaya on 16/06/25.
//

import SwiftUI

struct MissionFailedPopUp: View {
    @EnvironmentObject var gameData: GameData
    @Binding var currentLevel: Int
    @Binding var reason: String
    var isNewHighScore: Bool
    var onNextMission: () -> Void
    var body: some View {
        VStack {
            ZStack {
                Image("missionfailedbox")
                    .resizable()
                    .frame(width: 329, height: 160)

                Text(reason == "laut" ? "The Tree floats away..." : "Careful! Tree Crash!")
                    .font(Font.custom("Gugi", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 1, green: 0.42, blue: 0.36))
                    .frame(width: 306, alignment: .top)
                    .padding(.top, 15 + (-40))
                    .padding(.bottom, 47)

                    Text("MISSION FAILED")
                        .font(
                            Font.custom("Genos", size: 20.58992)
                                .weight(.regular)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 1, green: 0.42, blue: 0.36))
                        .padding(.top, 75 + (-40))
                        .padding(.bottom, 37)

                if isNewHighScore {
                    Text("New Highest Level: \(gameData.highestLevel)")
                        .font(
                            Font.custom("Genos", size: 20.58992)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(red: 0.94, green: 0.84, blue: 0.65)
                        )
                        .padding(.top, 140 + (-35))
                        .padding(.bottom, 37)
                } else {
                    Text("Your Level: \(currentLevel - 1)")
                        .font(
                            Font.custom("Genos", size: 20.58992)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(red: 0.94, green: 0.84, blue: 0.65)
                        )
                        .padding(.top, 140 + (-35))
                        .padding(.bottom, 37)
                }
            }

            Button(action: {
                onNextMission()
            }) {
                ZStack {
                    Image("buttonretry")

                    Text("TRY AGAIN")
                        .font(Font.custom("Gugi", size: 25.74193))
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(red: 0.02, green: 0.02, blue: 0.18)
                        )
                        .padding(.bottom, 14)
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    @Previewable @State var reason = "pohon"
    MissionFailedPopUp(
        currentLevel: .constant(3), reason: $reason, isNewHighScore: false,
        onNextMission: { print("retry game") }
    )
    .padding()
    .background(.black.opacity(0.5))
    .environmentObject(GameData())
}
