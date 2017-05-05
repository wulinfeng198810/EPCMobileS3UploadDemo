//
//  EPCAwsS3TaskModel.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import AWSS3

public typealias EPCAWSS3UploadTaskProgressBlock = (_ persent:CGFloat) -> ()
public typealias EPCAWSS3UploadTaskCompleteBlock = (_ isSuccess:Bool, _ error:NSError) -> ()

class EPCAwsS3TaskModel: NSObject {
    
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    
    var aws_identifier:String?
    
    var totalBytesSent:Int64 = 0
    var totalBytesExpectedToSend:Int64 = 0
    
}
