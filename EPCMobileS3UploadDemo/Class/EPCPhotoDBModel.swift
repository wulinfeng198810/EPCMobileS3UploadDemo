//
//  EPCPhotoDBModel.swift
//  FMDBTest
//
//  Created by Leo on 08/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AWSS3

class EPCPhotoDBModel: NSObject {
    
    // upload request task
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var totalBytesSent:Int64 = 0
    var totalBytesExpectedToSend:Int64 = 0
    
    // db property
    var pk:Int = -1
    var photoid:String?
    var transferState:EPCPhotoUploadState = .EPCPhotoUploadState_notStart
    var timestamp:String?
    
    enum EPCPhotoUploadState {
        case EPCPhotoUploadState_notStart
        case EPCPhotoUploadState_running
        case EPCPhotoUploadState_pause
        case EPCPhotoUploadState_cancel
        case EPCPhotoUploadState_failed
        case EPCPhotoUploadState_success
    }
    
    class func stateWithInt(int:Int32) -> EPCPhotoUploadState {
        
        var state = EPCPhotoUploadState.EPCPhotoUploadState_notStart
        
        switch int {
        case 0:
            state = EPCPhotoUploadState.EPCPhotoUploadState_notStart
            
        case 1:
            state = EPCPhotoUploadState.EPCPhotoUploadState_running
            
        case 2:
            state = EPCPhotoUploadState.EPCPhotoUploadState_pause
            
        case 3:
            state = EPCPhotoUploadState.EPCPhotoUploadState_cancel
            
        case 4:
            state = EPCPhotoUploadState.EPCPhotoUploadState_failed
            
        case 5:
            state = EPCPhotoUploadState.EPCPhotoUploadState_success
            
        default:
            state = EPCPhotoUploadState.EPCPhotoUploadState_notStart
        }
        
        return state
    }
}
