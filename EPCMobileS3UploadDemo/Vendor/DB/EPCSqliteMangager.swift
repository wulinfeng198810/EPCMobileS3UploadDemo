//
//  EPCSqlMangager.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

private let epc_db_path = "epc_db_path"
private let epc_db_name = "epc.sqlite"

class EPCSqliteMangager: NSObject {
    static let sharInstance:EPCSqliteMangager = EPCSqliteMangager()
    
//    func database()->FMDatabase {
//        
//        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        
//        path = path + epc_db_path
//        
//        let ret = FileManager.default.fileExists(atPath: "")
//
//        if ret == false {
//            try? FileManager.default.createDirectory(atPath: epcPhotoDir,
//                                                     withIntermediateDirectories: true,
//                                                     attributes: nil)
//        }
//
//        
//        path = path + epc_db_name
//        print("数据库的路径:" + path)
//        return FMDatabase.init(path:path)
//    }
//    
//    // MARK: - create table
//    
//    /// 创建表格
//    ///
//    /// - Parameters:
//    ///   - tableName: table name
//    ///   - arFields:  field
//    ///   - arFieldsType: field type
//    func epcCreateTable(tableName:String , arFields:NSArray, arFieldsType:NSArray){
//        let db = database()
//        if db.open() {
//            
//            var sql = "CREATE TALBLE IF NOT EXISTS " + tableName +
//            
//            var  sql = "CREATE TABLE IF NOT EXISTS " + tableName + "(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"
//            let arFieldsKey:[String] = arFields as! [String]
//            let arFieldsType:[String] = arFieldsType as! [String]
//            for i in 0..<arFieldsType.count {
//                if i != arFieldsType.count - 1 {
//                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ", "
//                }else{
//                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ")"
//                }
//            }
//            do{
//                try db.executeUpdate(sql, values: nil)
//                print("数据库操作====" + tableName + "表创建成功！")
//            }catch{
//                print(db.lastErrorMessage())
//            }
//            
//        }
//        db.close()
//        
//    }
}
