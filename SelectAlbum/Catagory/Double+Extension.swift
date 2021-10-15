//
//  Double+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/14.
//

import Foundation

extension Double {
    
    func getByteCountText() -> String {
        let K = self/1024.0
        if K < 100 {
            return String(Int(K)) + "K"
        }else {
            let M = K/1024
            return String(format: "%.1lf", M) + "M"
        }
    }
    
}
