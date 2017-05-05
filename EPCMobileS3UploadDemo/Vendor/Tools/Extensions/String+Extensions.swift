//
//  String+Extensions.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 05/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation

extension String {
    
    static func uuidString() -> String {
        return NSUUID().uuidString
    }
}
