import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var leftEyeView: UIImageView!
    @IBOutlet weak var rightEyeView: UIImageView!
    
    private var captureSession = AVCaptureSession()
    private var blinkTimer: Timer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置左眼和右眼的UIImageView为圆形
        makeImageViewCircular(leftEyeView)
        makeImageViewCircular(rightEyeView)
        
        // 设置摄像头捕获会话
        setupCamera()
        
        // 初始设置眼球位置
        resetEyesPosition()
        
        // 启动眨眼定时器
        startBlinkingTimer()
    }
    
    func makeImageViewCircular(_ imageView: UIImageView) {
        // 确保 UIImageView 是正方形，这样才能完全变成一个圆形
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
    }
    
    // 在视图布局完成后，重新设置眼球位置
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 确保在布局完成后设置眼球位置
        resetEyesPosition()
    }
    
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Error accessing camera: \(error)")
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        captureSession.addOutput(output)
        
        captureSession.startRunning()
    }
    
    func resetEyesPosition() {
        // 确保眼球在横屏模式下设置在正确的位置
        let leftEyeCenterX = view.frame.width * 0.25
        let rightEyeCenterX = view.frame.width * 0.75
        let eyeCenterY = view.frame.height * 0.5

        // 设置眼球位置
        leftEyeView.center = CGPoint(x: leftEyeCenterX, y: eyeCenterY)
        rightEyeView.center = CGPoint(x: rightEyeCenterX, y: eyeCenterY)
    }

    // AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let faceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectFaceHandler)
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])

        do {
            try imageRequestHandler.perform([faceRequest])
        } catch {
            print("Failed to perform face request: \(error)")
        }
    }
    
    func detectFaceHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation], let face = observations.first else { return }
        
        DispatchQueue.main.async {
            self.handleFaceObservation(face)
        }
    }
    
    func handleFaceObservation(_ face: VNFaceObservation) {
        guard let leftEye = face.landmarks?.leftEye, let rightEye = face.landmarks?.rightEye else { return }

        let middleEyePos = averageEyePosition(leftEye, boundingBox: face.boundingBox)

        moveEyes(middleEyePos: middleEyePos)
    }
    
    func averageEyePosition(_ eye: VNFaceLandmarkRegion2D, boundingBox: CGRect) -> CGPoint {
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        
        for point in eye.normalizedPoints {
            totalX += point.x
            totalY += point.y
        }
        
        let avgX = totalX / CGFloat(eye.pointCount)
        let avgY = totalY / CGFloat(eye.pointCount)
        
        // 将归一化坐标转换为屏幕坐标
        let x = avgX * boundingBox.width + boundingBox.origin.x
        let y = avgY * boundingBox.height + boundingBox.origin.y
        
        return CGPoint(x: x * view.frame.width, y: (1 - y) * view.frame.height) // 翻转 y 轴
    }

    func moveEyes(middleEyePos: CGPoint) {
        
        // 设置眼球最大移动范围
        let eyeMovementRange: CGFloat = 30
        var eyeOffsetX: CGFloat = 0

        // 获取当前左眼和右眼的原始中心位置
        let leftEyeOrigin = CGPoint(x: view.frame.width * 0.3, y: view.frame.height * 0.4)
        let rightEyeOrigin = CGPoint(x: view.frame.width * 0.7, y: view.frame.height * 0.4)
        

        // 计算眼睛相对于初始位置的偏移
        if (middleEyePos.x - leftEyeOrigin.x > 450 ) {
            eyeOffsetX = 2 * eyeMovementRange
        }
        else if (middleEyePos.x - leftEyeOrigin.x < 100){
            eyeOffsetX = -5 * eyeMovementRange
        }
        let eyeOffsetY = (middleEyePos.y - leftEyeOrigin.y)

        // 更新眼球位置，并应用合理的偏移修正
        UIView.animate(withDuration: 1.5) {
            self.leftEyeView.center = CGPoint(x: leftEyeOrigin.x + eyeOffsetY, y: leftEyeOrigin.y - eyeOffsetX)
            self.rightEyeView.center = CGPoint(x: rightEyeOrigin.x + eyeOffsetY, y: rightEyeOrigin.y - eyeOffsetX)
        }
    }
    
    // MARK: - 眨眼动画
    func startBlinkingTimer() {
        blinkTimer = Timer.scheduledTimer(timeInterval: Double.random(in: 3...7), target: self, selector: #selector(blinkEyes), userInfo: nil, repeats: true)
    }
    
    @objc func blinkEyes() {
        // 动画眨眼效果
        UIView.animate(withDuration: 0.2, animations: {
            self.leftEyeView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1) // 垂直缩小模拟眨眼
            self.rightEyeView.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
        }) { _ in
            // 还原眼球形状
            UIView.animate(withDuration: 0.2) {
                self.leftEyeView.transform = CGAffineTransform.identity
                self.rightEyeView.transform = CGAffineTransform.identity
            }
        }
    }
}
