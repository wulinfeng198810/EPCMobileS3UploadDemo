//
//  EPCSqliteMangager+EPCPhotoDBModel.swift
//  FMDBTest
//
//  Created by Leo on 08/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation

// MARK: - DB -> EPCPhotoDBModel
extension EPCSqliteMangager {
    
    
    /// insert photo dbModel
    ///
    /// - Parameter photo: photo dbModel
    /// - Returns: succeed or failed
    func insertPhotoDBModel(photo: EPCPhotoDBModel) -> Bool {
        
        let sql = "INSERT INTO EPCPhotoDBModel (photoid, transferState, timestamp) VALUES (?, ?, ?)"
        
        let values:[Any] = [photo.photoid ?? "no photoid",
                             photo.transferState.hashValue,
                             photo.timestamp ?? "0"]
        var ret = true
        
        fmdbQueue.inDatabase { (db) in
            do {
                try db?.executeUpdate(sql, values: values)
            } catch {
                debugPrint("\(#function) failed: \(error.localizedDescription)")
                ret = false
            }
        }
        
        return ret
    }
    
    
    /// query the all db datas of EPCPhotoDBModel with 'photoid'
    ///
    /// - Parameter withPhotoid: photoid
    /// - Returns: return [EPCPhotoDBModel]?
    func findAllPhotoDBModel(withPhotoid: String) -> [EPCPhotoDBModel]? {
        
        let sql = "SELECT * FROM EPCPhotoDBModel WHERE photoid = '\(withPhotoid)'"
        
        var array = Array<EPCPhotoDBModel>()
        
        fmdbQueue.inDatabase { (db) in
            
            do {
                guard let rs = try db?.executeQuery(sql, values: nil) else {
                    return
                }
                
                while rs.next() {
                    
                    if let photoid = rs.string(forColumn: "photoid"),
                        let timestamp = rs.string(forColumn: "timestamp") {
                        
                        let transferState = rs.int(forColumn: "transferState")
                        
                        let ts = EPCPhotoDBModel.stateWithInt(int: transferState)
                        
                        let photoModel = EPCPhotoDBModel()
                        photoModel.photoid = photoid
                        photoModel.transferState = ts
                        photoModel.timestamp = timestamp
                        
                        array.append(photoModel)
                    }
                }
                
            } catch {
                debugPrint("\(#function) failed: \(error.localizedDescription)")
            }
        }
        
        return array.count > 0 ? array : nil
    }
    
    
    /// query the first db data of EPCPhotoDBModel with 'photoid'
    ///
    /// - Parameter withPhotoid: photo id
    /// - Returns: return EPCPhotoDBModel?
    func findFirstPhotoDBModel(withPhotoid: String) -> EPCPhotoDBModel? {
        
        guard let array = findAllPhotoDBModel(withPhotoid: withPhotoid) else {
            return nil
        }
        
        return array[0]
    }
    
    
    /// update with 'photoid'
    ///
    /// - Parameters:
    ///   - withPhotoid: photo id
    ///   - toState: EPCPhotoDBModel.EPCPhotoUploadState
    /// - Returns: succeed or failed
    func updatePhotoDBModel(withPhotoid: String, toState:EPCPhotoDBModel.EPCPhotoUploadState) -> Bool {
        
        let stateInt = toState.hashValue
        
        let sql = "UPDATE EPCPhotoDBModel SET transferState = \(stateInt) WHERE photoid = '\(withPhotoid)'"
        
        var ret = true
        
        fmdbQueue.inDatabase { (db) in
            do {
                try db?.executeUpdate(sql, values: nil)
            } catch {
                debugPrint("\(#function) failed: \(error.localizedDescription)")
                ret = false
            }
        }
        
        return ret
    }
    
    
    /// delete with 'photoid'
    ///
    /// - Parameter withPhotoid: photo id
    /// - Returns: succeed or failed
    func deletePhotoDBModel(withPhotoid: String) -> Bool {
        
        let sql = "DELETE FROM EPCPhotoDBModel WHERE photoid = '\(withPhotoid)'"
        
        var ret = true
        
        fmdbQueue.inDatabase { (db) in
            do {
                try db?.executeUpdate(sql, values: nil)
            } catch {
                debugPrint("\(#function) failed: \(error.localizedDescription)")
                ret = false
            }
        }
        
        return ret
    }
    
}
