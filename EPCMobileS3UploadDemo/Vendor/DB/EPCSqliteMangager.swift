//
//  EPCSqlMangager.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import FMDB

private let epc_db_name = "epc.sqlite"

class EPCSqliteMangager:NSObject {
    
    static let shareInstance:EPCSqliteMangager = EPCSqliteMangager()
    var fmdbQueue:FMDatabaseQueue

    override init() {
        
        fmdbQueue = FMDatabaseQueue(path: EPCSqliteMangager.epcDBPath())
        super.init()
    }
    
    func openDB() {
        _ = createTable_EPCPhotoDBModel()
    }
    
    /// create table of EPCPhotoDBModel
    ///
    /// - Returns: succeed or failed
    func createTable_EPCPhotoDBModel() -> Bool {
        
        var ret = true
        
        fmdbQueue.inDatabase { (db) in
            
            do {
                try db?.executeUpdate("create table IF NOT EXISTS EPCPhotoDBModel(id integer PRIMARY KEY NOT NULL,photoid TEXT, transferState state, timestamp TEXT)", values: nil)
                
            } catch let error as NSError {
                
                epc_DebugForError(errorString:"\(#function) failed: \(error.localizedDescription)")
                
                ret = false
            }
        }
        
        return ret
    }

    
    /// EPC db path
    ///
    /// - Returns: db path
    private class func epcDBPath() -> String {
        
        var dbFinderURL = URL(fileURLWithPath: EPCDirectory.shareInstance.epcDBDirectory())
        
        debugPrint("\n EPC DB Path: \(dbFinderURL.path)")
        
        let ret = FileManager.default.fileExists(atPath: dbFinderURL.path)
        
        if ret == false {
            
            try? FileManager.default.createDirectory(atPath: dbFinderURL.path,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        
        dbFinderURL = dbFinderURL.appendingPathComponent(epc_db_name)
        
        return dbFinderURL.path
    }
}
