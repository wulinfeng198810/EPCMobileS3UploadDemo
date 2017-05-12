//
//  EPCAwsS3TaskManager.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import AWSS3
import AFNetworking

class EPCAwsS3TaskManager: NSObject {

    var uploadRequests = Array<EPCPhotoDBModel>()
    
    static let manager:EPCAwsS3TaskManager = EPCAwsS3TaskManager()
    
    /// is network reachable?
    var isNetworkReachable:Bool = true
    
    /// ture mean on wifi network, default is false that meaning on 2g/3g/4g network
    var isWiFi:Bool = false
    
    /// network transfer task could run when no-wifi(2g/3g/4g)
    var couldTransferWhenNoWiFi:Bool = false
}


// MARK: - aws s3
extension EPCAwsS3TaskManager {
    
    /// upload photo
    ///
    /// - Parameters:
    ///   - photo: EPCPhotoDBModel
    ///   - isNewTask: default is true, will auto save task to db
    ///   - continueHanler: block need note the NetworkReachable
    func upload(photo:EPCPhotoDBModel, isNewTask:Bool, continueHanler:((_ needNote: Bool)->())? = nil) {
        
        // MARK: insert into db
        if isNewTask == true {
            _ = EPCSqliteMangager.shareInstance.insertPhotoDBModel(photo: photo)
            
            if isNetworkReachable == false {
                continueHanler?(true)
                return
            }
            
            epc_alert(title: "您正在使用非wifi网络，上传图片将产生流量费用。", confirmHandler: {
                <#code#>
            })
        }
        
        photo.transferState = .EPCPhotoUploadState_running
        
        let s3TransferManager = AWSS3TransferManager.default()
        
        let uploadReq = AWSS3TransferManagerUploadRequest()
        
        guard let photoid = photo.photoid,
            let uploadRequest = uploadReq else {
            return
        }
        
        photo.uploadRequest = uploadRequest
        
        let fileUrl = URL.init(fileURLWithPath: photo.filePath)
        
        uploadRequest.bucket = EPC_S3BucketName
        uploadRequest.key = photoid + ".png"
        uploadRequest.body = fileUrl
        
        // progress block
        uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
            
            var persent = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
            persent = persent > 1 ? 1 : persent
            
            photo.totalBytesSent = totalBytesSent
            photo.totalBytesExpectedToSend = totalBytesExpectedToSend
            
            DispatchQueue.main.async(execute: {
                photo.progressBlock?(persent)
            })
        }
        
        // failed block
        let failedBlock:(_ error: NSError)->() = { (error: NSError) in
            
            photo.transferState = .EPCPhotoUploadState_failed
            _ = EPCSqliteMangager.shareInstance.updatePhotoDBModel(withPhotoid: photoid,
                                                                   toState: .EPCPhotoUploadState_failed)
            
            DispatchQueue.main.async(execute: {
                photo.completionHandler?(false, error)
            })
        }
        
        // success block
        let successBlock:()->() = {
            
            photo.transferState = .EPCPhotoUploadState_success
            _ = EPCSqliteMangager.shareInstance.updatePhotoDBModel(withPhotoid: photoid,
                                                                   toState: .EPCPhotoUploadState_success)
            
            DispatchQueue.main.async(execute: {
                photo.completionHandler?(true, nil)
            })
        }
        
        s3TransferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                
                /*
                if error.domain == AWSS3TransferManagerErrorDomain,
                    let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled:
                        failedBlock(error)
                        break
                        
                    case .paused:
                        failedBlock(error)
                        break
                        
                    default:
                        failedBlock(error)
                        debugPrint("Error uploading: \(String(describing: uploadRequest.key)) Error: \(error)")
                    }
                } else {
                    failedBlock(error)
                    debugPrint("Error uploading: \(String(describing: uploadRequest.key)) Error: \(error)")
                }
                */
                
                epc_DebugForError(errorString: error.localizedDescription)
                
                if error.code == 8 {
                    self.reqToken {
                        self.upload(photo: photo, isNewTask: false)
                    }
                } else {
                    failedBlock(error)
                }
                
                return nil
            }
            
            let result = task.result
            debugPrint("Upload complete for: \(String(describing: uploadRequest.key))")
            
            successBlock()
            
            return nil
        })
    }
    
    func changeUpload(photoModel:EPCPhotoDBModel) {
        if photoModel.transferState == .EPCPhotoUploadState_running {
            _ = photoModel.uploadRequest?.pause()
        }
        else
        {
            upload(photo: photoModel, isNewTask: false)
        }
    }
    
    func reqToken(complete:@escaping ()->()) {
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 10) {
            
            UserDefaults.standard.set("us-east-1:5f9bf9fb-937d-45e8-b715-7c9ac7d3f91d", forKey: "aws_id")
            UserDefaults.standard.set("eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTE6NWY5YmY5ZmItOTM3ZC00NWU4LWI3MTUtN2M5YWM3ZDNmOTFkIiwiYXVkIjoidXMtZWFzdC0xOmU5MmJkNWE4LTcxN2ItNGFmMi1iZjIwLWE1MThmYmRiN2RjYSIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZXBjbW9iaWxlIiwiZXBjbW9iaWxlOnVzLWVhc3QtMTplOTJiZDVhOC03MTdiLTRhZjItYmYyMC1hNTE4ZmJkYjdkY2E6NzU5Il0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZGVudGl0eS5hbWF6b25hd3MuY29tIiwiZXhwIjoxNDk0NTc3MjIxLCJpYXQiOjE0OTQ0OTA4MjF9.Vil3yRivZ-vI3CmWCpifwc4pYkV4hh3vXz20oIJJzdRUlk5ZTyLY1F76LmCexgqiYQYzV95MzICGgEbjJyBhaYIe95WBR2yn_VGLiJzhmZUzmz1arZOPZcsPDEcDHz9m7LSrdSeOYwaRcp-EpC-HdZa3ZlVl5gy4ZMfmGMvt3Gm-SjVtpMYBO6K-Lm0KyR7U4MjRTTyyAkDTx-w4aHO_S7z0eLnR-SchIvXMBUovOCwbyWZ6vACxj1zOYoSugA3MPlbZnti8J4Fo8mdC_xHqu9CRTNXcWTDsY-yQizEU6xQWludVrvaiHj5J25t29JwjHq3XUio2blWAGcux1HRGyA", forKey: "aws_token")
            
            UserDefaults.standard.synchronize()
            //            devAuth.token()
            
            complete()
        }
    }
    
}

// MARK: - Network monitor
extension EPCAwsS3TaskManager {
    
    
    /// Network monitor
    func networkMonitor(monitor:((_ isNetworkReachable:Bool, _ isWiFi:Bool)->())? = nil) {
        
        let reachabilityManager = AFNetworkReachabilityManager.shared()
        
        reachabilityManager.startMonitoring()
        
        reachabilityManager.setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) in
            
            var isNetworkReachable:Bool = true
            var isWiFi:Bool = true
            
            switch status {
                
            case .notReachable:
                isNetworkReachable = false
                isWiFi = false
                break
                
            case .reachableViaWWAN:
                isNetworkReachable = true
                isWiFi = false
                break
                
            default:
                isNetworkReachable = true
                isWiFi = true
            }
            
            self.isWiFi = isWiFi
            self.isNetworkReachable = isNetworkReachable
            
            self.promptNetworkReachability(isNetworkReachable: isNetworkReachable,
                                      isWiFi: isWiFi)
            
            monitor?(isNetworkReachable, isWiFi)
        }
    }
    
    private func promptNetworkReachability(isNetworkReachable:Bool, isWiFi:Bool) {
        
        var promptText:String = ""
        if isNetworkReachable {
            
            if isWiFi {
                promptText = "current network is wifi network"
            } else {
                promptText = "current network is non-wifi network"
            }
            
        } else {
            promptText = "current network is unavalible"
        }
        
        debugPrint("*** network reachability status changed ****",
                   "",
                   promptText,
                   "",
                   "******************* end ********************",
                   separator: "\n",
                   terminator: "\n")
    }
}
