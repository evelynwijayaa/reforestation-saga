//
//  CamerCheckView.swift
//  ReforestationSaga
//
//  Created by Nur Fajar Sayyidul Ayyam on 16/06/25.
//

import SwiftUI

struct CameraCheckView: View {
    @EnvironmentObject var detector: EyeBlinkDetectorVision
    @State private var showAlert = false
    @State private var navigateToNextPage = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraViewVision(eyeBlinkDetector: detector)
                .edgesIgnoringSafeArea(.all)
            Image("camera-bg")
                .resizable()
                .ignoresSafeArea()
            if showAlert {
                AccessGrantedPopUp()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
        .onChange(of: detector.blinkCount) {
            if detector.blinkCount > 0 {
                showAlert = true
                GameMusicManager.shared.playSoundEffect(filename: "access-granted")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                navigateToNextPage = true
            }
        }
        .navigationDestination(isPresented: $navigateToNextPage) {
            MailView()
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    CameraCheckView()
        .environmentObject(EyeBlinkDetectorVision())
}
