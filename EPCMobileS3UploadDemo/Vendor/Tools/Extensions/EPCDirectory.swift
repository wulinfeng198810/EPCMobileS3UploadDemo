//
//  Bundle+Extensions.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation

private let photoFinderName = "EPC-Photo"

class EPCDirectory {
    
    static let shareInstance: EPCDirectory = EPCDirectory()
    
    func deploy() {
        
        let epcPhotoDir = epcPhotoDirectory()
        
        let ret = FileManager.default.fileExists(atPath: epcPhotoDir)
        
        if ret == false {
            try? FileManager.default.createDirectory(atPath: epcPhotoDir,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
    }
    
    func documentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    func epcPhotoDirectory() -> String {
        return documentDirectory() + "/" + "\(photoFinderName)"
    }
}
