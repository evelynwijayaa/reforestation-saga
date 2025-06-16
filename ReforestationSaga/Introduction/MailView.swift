//
//  MailView.swift
//  ReforestationSaga
//
//  Created by Gibran Shevaldo on 14/06/25.
//

import SwiftUI

struct MailView: View {
    @State private var isSoundOn = true
    @State private var navigateToGame = false
    @State private var showCurrentView = true
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image("background")
                    .ignoresSafeArea()
                
                HStack {
                    ZStack {
                        Image("box")
                            .resizable()
                            .frame(width: 140, height: 31)
                        Text("Highest Level 0")
                            .font(Font.custom("Gugi", size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                            .padding(.bottom, 8)
                    }
                    
                }
                .padding(.top, 60)
                
                // Main
                if showCurrentView {
                    Button(action: {
                        isSoundOn.toggle()
                    }) {
                        Image(isSoundOn ? "sound" : "soundoff")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }
                    .padding(.leading, 300)
                    .padding(.top, 55)
                    .zIndex(2)
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        ZStack {
                            Image("box")
                                .resizable()
                                .frame(width: 140, height: 31)
                            Text("Highest Level 0")
                                .font(Font.custom("Gugi", size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.94, green: 0.84, blue: 0.65))
                                .padding(.bottom, 8)
                        }
                        
                    }
                    .padding(.top, 60)
                    
                    Button(action: {
                        isSoundOn.toggle()
                    }) {
                        Image(isSoundOn ? "sound" : "soundoff")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }
                    .padding(.leading, 300)
                    .padding(.top, 55)
                    .zIndex(2)
                    .buttonStyle(PlainButtonStyle())
                    
                    GeometryReader { geometry in
                        VStack {
                            Image("email")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400, height: 274)
                        }
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height / 2)
                        
                        VStack {
                            Image("message")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 274)
                                .onTapGesture {
                                    performFadeTransition()
                                }
                        }
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width / 2,
                                  y: geometry.size.height / 1.88)
                    }
                }
                
                if navigateToGame {
                    IntroView()
                }
            }
        }
    }
    private func performFadeTransition() {
       withAnimation(.easeOut(duration: 0.2)) {
           showCurrentView = false
       }
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           withAnimation(.easeIn(duration: 0.2)) {
               navigateToGame = true
           }
       }
   }
}

#Preview {
    MailView()
}
