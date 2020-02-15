//
//  ScanViewController.swift
//  QRCode
//
//  Created by Billow on 2020/2/6.
//  Copyright © 2020 Billow Wang. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取后置摄像头
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            captureSession.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            print(error)
            return
        }
        // 展示视频流
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession.startRunning()
        
        // 突出显示二维码
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            self.view.addSubview(qrCodeFrameView)
            self.view.bringSubviewToFront(qrCodeFrameView)
        }
        
    }
    //
    //    func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
    //      layer.videoOrientation = orientation
    //      videoPreviewLayer?.frame = self.view.bounds
    //    }
    //
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //
    //        if let connection =  self.videoPreviewLayer?.connection  {
    //            let currentDevice: UIDevice = UIDevice.current
    //            let orientation: UIDeviceOrientation = currentDevice.orientation
    //            let previewLayerConnection : AVCaptureConnection = connection
    //
    //            if previewLayerConnection.isVideoOrientationSupported {
    //                switch (orientation) {
    //                case .portrait:
    //                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
    //                    break
    //                case .landscapeRight:
    //                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
    //                    break
    //                case .landscapeLeft:
    //                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
    //                    break
    //                case .portraitUpsideDown:
    //                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
    //                    break
    //                default:
    //                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
    //                    break
    //                }
    //            }
    //        }
    //    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 检查 metadataObjects 是否为空
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QR code is detected")
            return
        }
        
        // 获取元数据对象
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // 判断解析到的数据
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            // 元数据对象的视觉属性将转换为图层坐标
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            // 更新图层的frame, 显示绿色边框
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            // 获取二维码中的字符串信息
            if let qrcode = metadataObj.stringValue {
                print(qrcode)
                
                let resultViewController = storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
                resultViewController.qrcode = qrcode
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(resultViewController, animated: true, completion: nil)
            }
        }
    }
}
