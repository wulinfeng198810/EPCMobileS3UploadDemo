//
//  EPCConstant.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

let EPC_S3BucketName = "epc-lio-photo"

func epc_DebugForError(errorString:String) {
    let sep = "**************************************"
    
    debugPrint(sep, errorString, sep, separator: "\n", terminator: "\n")
}

func epc_alert(title:String?, message: String? = nil, confirmHandler:(()->())?, cancleHandler:(()->())? = nil) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let rootVC = appDelegate?.window?.rootViewController
    
    let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
        confirmHandler?()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        cancleHandler?()
    }
    
    sheet.addAction(confirmAction)
    sheet.addAction(cancelAction)
    
    rootVC?.present(sheet, animated: true, completion: nil)
}

func epc_AlertMessage(title:String?, message: String? = nil, confirmHandler:(()->())?) {
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let rootVC = appDelegate?.window?.rootViewController
    
    let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
        confirmHandler?()
    }
    
    sheet.addAction(confirmAction)
    
    rootVC?.present(sheet, animated: true, completion: nil)
}
