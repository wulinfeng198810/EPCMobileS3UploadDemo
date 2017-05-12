//
//  UIImage+Extentsions.swift
//  Weibo
//
//  Created by LioWu on 16/04/2017.
//  Copyright © 2017 MyGit. All rights reserved.
//

import Foundation

extension UIImage {
    
    func epc_avatarImage(size:CGSize?, backgroundColor:UIColor? = UIColor.white, lineColor:UIColor? = UIColor.lightGray) -> UIImage? {
        
        var toSize = size
        if toSize == nil {
            toSize = self.size
        }
        
        let rect = CGRect.init(origin: CGPoint.zero, size: toSize!)
        // 获取上下文
        // opaque: 不透明 false / true
        // scale：屏幕分辨率，默认为1，绘图质量不好；设为0，会选择当前屏幕分辨率
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        backgroundColor?.setFill()
        UIRectFill(rect)
        
        let path = UIBezierPath.init(ovalIn: rect)
        path.addClip()
        
        let ovalpath = UIBezierPath.init(ovalIn: rect)
        lineColor?.setFill()
        ovalpath.lineWidth = 2.0
        ovalpath.stroke()
        
        draw(in: rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func epc_scaleImage(size:CGSize?) -> UIImage? {
        
        var toSize = size
        if toSize == nil {
            toSize = self.size
        }
        
        let rect = CGRect.init(origin: CGPoint.zero, size: toSize!)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        draw(in: rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
}
