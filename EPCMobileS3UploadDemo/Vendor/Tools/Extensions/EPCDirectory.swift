//
//  Bundle+Extensions.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation

// photo finder
private let photo_path = "epc-photo"

// db finder
private let epc_db_path = "epc-db-path"

class EPCDirectory {
    
    static let shareInstance:EPCDirectory = EPCDirectory()
    
    func deploy() {
        
        let finders = [epcPhotoDirectory(),
                       epcDBDirectory()]
        
        for path in finders {
            
            let ret = FileManager.default.fileExists(atPath: path)
            if ret {
                continue
            }
            
            do {
                try FileManager.default.createDirectory(atPath: path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
            } catch let error as NSError {
                debugPrint("\(#function) failed: \(error.localizedDescription)")
            }
        }
    }
    
    func documentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    func epcPhotoDirectory() -> String {
        return documentDirectory() + "/" + "\(photo_path)"
    }
    
    func epcDBDirectory() -> String {
        return documentDirectory() + "/" + "\(epc_db_path)"
    }
}
