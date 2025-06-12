//
//  EyeBlinkDetector.swift
//  TestProject3(App)
//
//  Created by Muhammad Irhamdi Fahdiyan Noor on 10/06/25.
//

import Foundation
import AVFoundation
import CoreML
import Vision

class EyeBlinkDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let model = try! EyeModel(configuration: MLModelConfiguration())

    @Published var predictionLabel: String = "No Face"
    @Published var isFaceDetected: Bool = false

    private var lastBlinkTime: Date = .distantPast
    private let blinkInterval: TimeInterval = 1.0 // 1 second limit between blinks

    func startCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera)
        else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // VNDetectFaceRectanglesRequest digunakan untuk cek wajah
        let faceRequest = VNDetectFaceRectanglesRequest { [weak self] request, _ in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if request.results?.isEmpty == false {
                    self.isFaceDetected = true
                } else {
                    self.isFaceDetected = false
                    self.predictionLabel = "No Face"
                }
            }

            guard self.isFaceDetected else { return }

            guard let input = try? EyeModelInput(image: pixelBuffer),
                  let prediction = try? self.model.prediction(input: input) else { return }

            let target = prediction.target
            let probability = prediction.targetProbability[target] ?? 0

            // Optional threshold
            if target == "closed_eye" && probability > 0.95 {
                if Date().timeIntervalSince(self.lastBlinkTime) >= self.blinkInterval {
                    self.lastBlinkTime = Date()
                    DispatchQueue.main.async {
                        self.predictionLabel = "Blink detected"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.predictionLabel = target // opened_eye / closed_eye
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([faceRequest])
    }
}
