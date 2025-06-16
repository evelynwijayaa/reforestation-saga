//
//  TestProject3_App_App.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SwiftUI

@main
struct ReforestationSaga_App: App {
    @StateObject private var detector = EyeBlinkDetectorVision()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(detector)
        }
    }
}
