//
//  EyeBlinkDetectorVision.swift
//  TestProject3(App)
//
//  Created by Nur Fajar Sayyidul Ayyam on 12/06/25.
//

import AVFoundation
import SwiftUI
import Vision

struct EyeBlinkDetectorVision: UIViewRepresentable {
    @ObservedObject var coordinator: Coordinator
    @State private var isFrontCamera = true

    func makeUIView(context: Context) -> CameraPreviewViewVision {
        let view = CameraPreviewViewVision()
        coordinator.setupCamera(
            in: view, usingFrontCamera: isFrontCamera)

        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            context.coordinator,
            action: #selector(coordinator.switchCameraTapped),
            for: .touchUpInside)

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -30),
        ])

        let blinkLabel = UILabel()
        blinkLabel.text = "Blink: 0"
        blinkLabel.textColor = .white
        blinkLabel.font = UIFont.boldSystemFont(ofSize: 20)
        blinkLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(blinkLabel)

        NSLayoutConstraint.activate([
            blinkLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            blinkLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: 40),
        ])

        coordinator.blinkCountLabel = blinkLabel

        return view
    }

    func updateUIView(_ uiView: CameraPreviewViewVision, context: Context) {}

//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
}

class Coordinator: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var overlayLayer = CAShapeLayer()

    private var currentCameraPosition: AVCaptureDevice.Position = .front

    private var videoOutput = AVCaptureVideoDataOutput()

    @Published var blinkCount = 0
    private var isEyeClosed = false
    var frameCount = 0

    var blinkCountLabel: UILabel?

    func setupCamera(in view: CameraPreviewViewVision, usingFrontCamera: Bool) {
        session.beginConfiguration()
        session.sessionPreset = .high

        session.inputs.forEach { session.removeInput($0) }
        currentCameraPosition = usingFrontCamera ? .front : .back

        guard let device = getCamera(for: currentCameraPosition),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        session.outputs.forEach { session.removeOutput($0) }

        videoOutput.setSampleBufferDelegate(
            self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()

        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
            if let previewLayer = previewLayer {
                view.layer.insertSublayer(previewLayer, at: 0)
            }
        }
        previewLayer?.session = session

        overlayLayer.strokeColor = UIColor.red.cgColor
        overlayLayer.lineWidth = 2
        overlayLayer.fillColor = UIColor.clear.cgColor
        if overlayLayer.superlayer == nil {
            view.layer.addSublayer(overlayLayer)
        }
        view.overlayLayer = overlayLayer
        view.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    private func getCamera(for position: AVCaptureDevice.Position)
        -> AVCaptureDevice?
    {
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        ).devices
        return devices.first
    }

    @objc func switchCameraTapped() {
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }

        currentCameraPosition =
            (currentCameraPosition == .back) ? .front : .back

        guard let newDevice = getCamera(for: currentCameraPosition),
            let newInput = try? AVCaptureDeviceInput(device: newDevice)
        else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }

        session.commitConfiguration()
    }

    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        frameCount += 1
        guard frameCount % 3 == 0 else { return } // Proses setiap 3 frame sekali
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        let request = VNDetectFaceLandmarksRequest {
            [weak self] request, error in
            guard let self = self,
                let results = request.results as? [VNFaceObservation],
                let previewLayer = self.previewLayer
            else { return }

            DispatchQueue.main.async {
                self.overlayLayer.sublayers?.forEach {
                    $0.removeFromSuperlayer()
                }

                if let largestFace = results.max(by: {
                    ($0.boundingBox.width * $0.boundingBox.height)
                        < ($1.boundingBox.width * $1.boundingBox.height)
                }) {
                    let face = largestFace
                    let faceBox = self.createBoundingBox(
                        for: face.boundingBox, in: previewLayer)
                    self.overlayLayer.addSublayer(faceBox)

                    if let landmarks = face.landmarks,
                        let leftEye = landmarks.leftEye,
                        let rightEye = landmarks.rightEye
                    {

                        let leftEAR = self.computeEyeAspectRatio(leftEye)
                        let rightEAR = self.computeEyeAspectRatio(rightEye)
                        let avgEAR = (leftEAR + rightEAR) / 2.0

                        if avgEAR < 0.15 {
                            if !self.isEyeClosed {
                                self.isEyeClosed = true
                            }
                        } else {
                            if self.isEyeClosed {
                                self.blinkCount += 1
                                DispatchQueue.main.async {
                                    self.blinkCountLabel?.text =
                                        "Blink: \(self.blinkCount)"
                                }
//                                print("Blink Count: \(self.blinkCount)")
                                self.isEyeClosed = false
                            }
                        }

                        self.overlayLayer.addSublayer(
                            self.drawLandmark(
                                leftEye, for: face, in: previewLayer))
                        self.overlayLayer.addSublayer(
                            self.drawLandmark(
                                rightEye, for: face, in: previewLayer))
                    }
                }

                //                    for face in results {
                //                        let faceBox = self.createBoundingBox(for: face.boundingBox, in: previewLayer)
                //                        self.overlayLayer.addSublayer(faceBox)
                //
                //                        if let landmarks = face.landmarks {
                //                            if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
                //                                let leftEAR = self.computeEyeAspectRatio(leftEye)
                //                                let rightEAR = self.computeEyeAspectRatio(rightEye)
                //                                let avgEAR = (leftEAR + rightEAR) / 2.0
                //
                //                                if avgEAR < 0.2 {
                //                                    if !self.isEyeClosed {
                //                                        self.isEyeClosed = true
                //                                    }
                //                                } else {
                //                                    if self.isEyeClosed {
                //                                        self.blinkCount += 1
                //                                        DispatchQueue.main.async {
                //                                            self.blinkCountLabel?.text = "Blink: \(self.blinkCount)"
                //                                        }
                //                                        print("Blink Count: \(self.blinkCount)")
                //                                        self.isEyeClosed = false
                //                                    }
                //                                }
                //
                //                                self.overlayLayer.addSublayer(self.drawLandmark(leftEye, for: face, in: previewLayer))
                //                                self.overlayLayer.addSublayer(self.drawLandmark(rightEye, for: face, in: previewLayer))
                //                            }
                //                        }
                //                    }
            }
        }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: currentCameraPosition == .front
                ? .leftMirrored : .right, options: [:])
        try? handler.perform([request])
    }

    private func createBoundingBox(
        for rect: CGRect, in layer: AVCaptureVideoPreviewLayer
    ) -> CAShapeLayer {
        let convertedRect = convertBoundingBox(rect, in: layer)
        let path = UIBezierPath(rect: convertedRect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }

    private func convertBoundingBox(
        _ boundingBox: CGRect, in layer: AVCaptureVideoPreviewLayer
    ) -> CGRect {
        let size = layer.bounds.size
        let x = boundingBox.origin.x * size.width
        let height = boundingBox.size.height * size.height
        let y = (1 - boundingBox.origin.y) * size.height - height
        let width = boundingBox.size.width * size.width
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func drawLandmark(
        _ landmark: VNFaceLandmarkRegion2D, for face: VNFaceObservation,
        in layer: AVCaptureVideoPreviewLayer
    ) -> CAShapeLayer {
        let path = UIBezierPath()
        let points = landmark.normalizedPoints

        for i in 0..<points.count {
            let point = points[i]
            let converted = VNImagePointForFaceLandmarkPoint(
                point, face.boundingBox, Int(layer.bounds.width),
                Int(layer.bounds.height))
            if i == 0 {
                path.move(to: converted)
            } else {
                path.addLine(to: converted)
            }
        }
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.clear.cgColor

        return shapeLayer
    }

    private func VNImagePointForFaceLandmarkPoint(
        _ point: CGPoint, _ boundingBox: CGRect, _ width: Int, _ height: Int
    ) -> CGPoint {
        let x = boundingBox.origin.x + point.x * boundingBox.size.width
        let y = boundingBox.origin.y + point.y * boundingBox.size.height
        return CGPoint(
            x: CGFloat(x) * CGFloat(width),
            y: (1 - CGFloat(y)) * CGFloat(height))
    }

    private func computeEyeAspectRatio(_ eye: VNFaceLandmarkRegion2D)
        -> CGFloat
    {
        guard eye.pointCount >= 6 else { return 0 }

        let p2 = eye.normalizedPoints[1]
        let p6 = eye.normalizedPoints[5]
        let p3 = eye.normalizedPoints[2]
        let p5 = eye.normalizedPoints[4]
        let p1 = eye.normalizedPoints[0]
        let p4 = eye.normalizedPoints[3]

        let vertical1 = hypot(p2.x - p6.x, p2.y - p6.y)
        let vertical2 = hypot(p3.x - p5.x, p3.y - p5.y)
        let horizontal = hypot(p1.x - p4.x, p1.y - p4.y)

        return (vertical1 + vertical2) / (2.0 * horizontal)
    }
}

class CameraPreviewViewVision: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var overlayLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        overlayLayer?.frame = bounds
    }
}
