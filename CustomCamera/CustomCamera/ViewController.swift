//
//  ViewController.swift
//  CustomCamera
//
//  Created by Likhit Garimella on 10/06/19.
//  Copyright © 2019 Likhit Garimella. All rights reserved.
//

//This project of Brian Advent if of Swift 3
//It is modified to Swift 4 for this version

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession() //Coordinates b/w input & output later on
    
    var previewLayer: CALayer!  //To dosplay datastream on ViewController
    
    var captureDevice: AVCaptureDevice!
    
    var takePhoto = false   //Initially bool set to false

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
        // Do any additional setup after loading the view.
    }
    
    //Function to prepare our camera
    
    func prepareCamera()    {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo    //This selects the bass configuration for the capte of a photo
        
        //Now we need to check if we actually have devices available
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        //Here, no need to use if let statement as told in Youtube because, The initializer of AVCaptureVideoPreviewLayer doesn't return an optional. Thus, the if condition is always true, and the if statement is useless. You should remove the 'if' and it's braces.
        

        
            captureDevice = availableDevices.first
            beginSession()  //Only if there is an available device, session begins
        
    }
    
    func beginSession()
    {
        do
        {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            //Thread 1: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
            //It means your variable is set to nil, but your code is expecting it to not be nil.
            
            
            //Adding device to the session
            captureSession.addInput(captureDeviceInput)
        }   catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //Here, no need to use if let statement as told in Youtube because, The initializer of AVCaptureVideoPreviewLayer doesn't return an optional. Thus, the if condition is always true, and the if statement is useless. You should remove the 'if' and it's braces.

        
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
            
            //For Output:-
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            //See whether capture session can pass output
            if captureSession.canAddOutput(dataOutput)
            {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            //To actually capture something from the stream
            let queue = DispatchQueue(label: "com.likhitgarimella.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)
    {
        if takePhoto
        {
            takePhoto = false   //Setting to false bcuz we just need 1 photo
            //Here we are going to get image from sample buffer
            
            //After we get the image,
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer)
            {
                //Here we create a photo view controller
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
                
                photoVC.takenPhoto = image
                
                DispatchQueue.main.async {
                    
                    self.present(photoVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage?  //We return an image
    {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            //Here we use ci and not CI bcuz variable shouldn't be used within its own initial value
            let context = CIContext()
            
            //For dimension resize and position:-
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))  //Now we have the dimensions of the image
            
            if let image = context.createCGImage(ciImage, from: imageRect)
            {
                //Here we get the image and we return it
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        
        }
        //if none of this works,
        return nil
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

