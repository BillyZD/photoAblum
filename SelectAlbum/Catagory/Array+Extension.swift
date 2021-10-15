//
//  Array+Extension.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/14.
//

import Foundation

extension Array {
    
    func safeIndex(_ index: Int) -> Element? {
        guard index >= 0  , index < self.count else { return nil}
        return self[index]
    }
    
}
