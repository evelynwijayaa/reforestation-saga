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
        }
        .onChange(of: detector.blinkCount) {
            if detector.blinkCount > 0 {
                showAlert = true
            }
        }
        .alert("Access Granted", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                navigateToNextPage = true
            }
        }
        .navigationDestination(isPresented: $navigateToNextPage) {
            IntroView()
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    CameraCheckView()
        .environmentObject(EyeBlinkDetectorVision())
}
