//
//  ViewController.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 02/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AWSS3

class ViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    var s3TransferManager: AWSS3TransferManager?
    
    var uploadRequest: AWSS3TransferManagerUploadRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startAction(_ sender: Any) {
        upload()
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        
        guard let req = uploadRequest else {
            
    
            return
        }
        
        if req.state == .running {
            
            
            req.pause()
        }
        else {
            s3TransferManager?.resumeAll({ (resumeReq) in
                print(resumeReq)
            })
        }
        
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        imagePicker()
    }
    
    @IBAction func resumeAll(_ sender: Any) {
        s3TransferManager?.resumeAll({ (resumeReq) in
            print(resumeReq)
        })
    }
    
}


extension ViewController {
    
    func upload() {
        
//        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        print(docPath)
        
        s3TransferManager = AWSS3TransferManager.default()
        
//        let filePath = "/Users/leo/Desktop/ios-CoreAnimation.pdf"
//        let filePath = "/Users/leo/Desktop/redMountain.png"
        
        guard let filePath = Bundle.main.path(forResource: "screen.png", ofType: nil) else {
            
            refreshPrompt(prompt: "File not found！")
            
            return
        }
        
        let fileUrl = URL.init(fileURLWithPath: filePath)
        
        uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "epc-lio-photo"
        
        let key = (filePath as NSString).lastPathComponent
        
        uploadRequest?.key = key
        
        uploadRequest?.body = fileUrl
        
        uploadRequest?.uploadProgress = {[weak self] (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            let persent = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
            
            DispatchQueue.main.async(execute: { 
                self?.progress.progress = Float(persent)
                
                let persentStr = NSString(format: "%.2f%%", persent*100) as String
                self?.refreshPrompt(prompt: persentStr)
            })
        }
        
        let failedBlock:(_ error: NSError)->() = { (error: NSError) in
            self.refreshPrompt(prompt: error.localizedDescription)
        }
        
        let successBlock:()->() = {
            self.refreshPrompt(prompt: "complete!")
        }
        
        
        s3TransferManager?.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled:
                    failedBlock(error)
                        break
                        
                    case .paused:
                    failedBlock(error)
                        break
                        
                    default:
                        failedBlock(error)
                        print("Error uploading: \(String(describing: self.uploadRequest?.key)) Error: \(error)")
                    }
                } else {
                    failedBlock(error)
                    print("Error uploading: \(String(describing: self.uploadRequest?.key)) Error: \(error)")
                }
                
                if error.code == 8 {
                    self.reqToken {
                        self.upload()
                    }
                }
                
                return nil
            }
            
            let result = task.result
            print("Upload complete for: \(String(describing: self.uploadRequest?.key))")
            
            successBlock()
            
            return nil
        })
        
    }
    
    func refreshPrompt(prompt: String) {
        DispatchQueue.main.async { 
            self.promptLabel.text = prompt
        }
    }
    
    func reqToken(complete:@escaping ()->()) {
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10) {
            
            UserDefaults.standard.set("us-east-1:5f9bf9fb-937d-45e8-b715-7c9ac7d3f91d", forKey: "aws_id")
            UserDefaults.standard.set("eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTE6NWY5YmY5ZmItOTM3ZC00NWU4LWI3MTUtN2M5YWM3ZDNmOTFkIiwiYXVkIjoidXMtZWFzdC0xOmU5MmJkNWE4LTcxN2ItNGFmMi1iZjIwLWE1MThmYmRiN2RjYSIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZXBjbW9iaWxlIiwiZXBjbW9iaWxlOnVzLWVhc3QtMTplOTJiZDVhOC03MTdiLTRhZjItYmYyMC1hNTE4ZmJkYjdkY2E6NzU5Il0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZGVudGl0eS5hbWF6b25hd3MuY29tIiwiZXhwIjoxNDkzOTczMjM1LCJpYXQiOjE0OTM4ODY4MzV9.VHH9wl8SNwub8PKboBZpG0xJtYh-7rHvDSgIN5FacLxT4FaggnoIK0crkS4HQkelIYCcMCbvT5qpOuu6MY9l7hBkfLEke1XdhGemQFXj7_oygoymB3PZFsDBzXYOUwYzmDpRWBS5Dg2IUQRcaAACv-DL3pW4hvZ_yPynjUj_aLvmpSML9bBpmqKKUYVvHA90cxr9-njQHwOOl9BA_SZBSFa__tLTImfpU0ARayhOWNxf2UuTKjs4L6p4TIJv6dPZvDDIDS76e4g_PNuCQ4Z7LnBFrn2Q_5wwXpZ4bEcF3BeTYh6daM_XkzxYTnlGNcY8P6D60AhukJTrYUGOrGLBZA", forKey: "aws_token")
            
            UserDefaults.standard.synchronize()
            //            devAuth.token()
            
            complete()
        }
    }
    
//    func multiUpload() {
//        
//        let s3TransferManager = AWSS3TransferManager.default()
//        
//        let s3server = AWSService()
//        
//        //        let filePath = "/Users/leo/Desktop/ios-CoreAnimation.pdf"
//        let filePath = "/Users/leo/Desktop/redMountain.png"
//        
//        let fileUrl = URL.init(fileURLWithPath: filePath)
//        
//        let multiUploadRequest = AWSS3CreateMultipartUploadRequest()
//        
//        multiUploadRequest?.bucket = "epc-lio-photo"
//        
//        let key = (filePath as NSString).lastPathComponent
//        
//        multiUploadRequest?.key = key
//        
//        s3server
//        
//        //        multiUploadRequest?.body = fileUrl
//        
//        
//        
//    }
    
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
    }
    
}
