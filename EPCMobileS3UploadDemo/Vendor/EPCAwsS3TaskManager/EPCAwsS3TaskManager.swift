//
//  EPCAwsS3TaskManager.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import AWSS3


class EPCAwsS3TaskManager: NSObject {

    var uploadRequests = Array<EPCPhotoDBModel>()
    
    static let manager:EPCAwsS3TaskManager = EPCAwsS3TaskManager()
}


extension EPCAwsS3TaskManager {
    
    func upload(photo:EPCPhotoDBModel) {
        
        let s3TransferManager = AWSS3TransferManager.default()
        
        guard let filePath = Bundle.main.path(forResource: "screen.png", ofType: nil) else {
            return
        }
        
        let fileUrl = URL.init(fileURLWithPath: filePath)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "epc-lio-photo"
        
        uploadRequest?.key = photo.photoid! + ".png"
        
        uploadRequest?.body = fileUrl
        
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            let persent = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
            photo.totalBytesSent = totalBytesSent
            photo.totalBytesExpectedToSend = totalBytesExpectedToSend
            debugPrint("progress: \(persent)")
        }
        
        let failedBlock:(_ error: NSError)->() = { (error: NSError) in
            _ = EPCSqliteMangager.shareInstance.updatePhotoDBModel(withPhotoid: photo.photoid!, toState: .EPCPhotoUploadState_failed)
        }
        
        let successBlock:()->() = {
            _ = EPCSqliteMangager.shareInstance.updatePhotoDBModel(withPhotoid: photo.photoid!, toState: .EPCPhotoUploadState_success)
        }
        
        
        s3TransferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
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
                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                    }
                } else {
                    failedBlock(error)
                    print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                }
                
                if error.code == 8 {
                    self.reqToken {
                        self.upload(photo: photo)
                    }
                }
                
                return nil
            }
            
            let result = task.result
            print("Upload complete for: \(String(describing: uploadRequest?.key))")
            
            successBlock()
            
            return nil
        })
        
    }
    
    func reqToken(complete:@escaping ()->()) {
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10) {
            
            UserDefaults.standard.set("us-east-1:5f9bf9fb-937d-45e8-b715-7c9ac7d3f91d", forKey: "aws_id")
            UserDefaults.standard.set("eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTE6NWY5YmY5ZmItOTM3ZC00NWU4LWI3MTUtN2M5YWM3ZDNmOTFkIiwiYXVkIjoidXMtZWFzdC0xOmU5MmJkNWE4LTcxN2ItNGFmMi1iZjIwLWE1MThmYmRiN2RjYSIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZXBjbW9iaWxlIiwiZXBjbW9iaWxlOnVzLWVhc3QtMTplOTJiZDVhOC03MTdiLTRhZjItYmYyMC1hNTE4ZmJkYjdkY2E6NzU5Il0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZGVudGl0eS5hbWF6b25hd3MuY29tIiwiZXhwIjoxNDk0NDAxMjIyLCJpYXQiOjE0OTQzMTQ4MjJ9.Bx-NVb5jlCGYYojrbUzTgq3MlmIdHcs0je5UOlDvUJsFGegV0_wYnvUNt2DKaJ1zfdYKXKCPgFK55S9TQTbp29fj90UcQ7nkLEYw176FiNEK7GwXoSnJFyuZZbjz64HKAS7e8Dlz9H7uPCyNgxDBg1Oet16gXOJY_fAUeotntVNKcs5E29Hp4HXDyigXR5gRSDgMjLUwAdgtx3t7xrU7CMKeYV69lySqIIZAcabnJNjroT2qWjb-IsnXrgzEjwR-xd38s60ZAWEWw-zCORmcONPzgGWi3x7Ud45nAfUQmL8wXftsQs197z7d7nnZ-Y52M_WJ0IAojT4i6cuQ6Jcufg", forKey: "aws_token")
            
            UserDefaults.standard.synchronize()
            //            devAuth.token()
            
            complete()
        }
    }
    
}
