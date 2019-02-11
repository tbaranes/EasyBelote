//
//  ArrayExtension.swift
//  KaraFun Quiz Core iOS
//
//  Created by Tom Baranes on 07/11/2017.
//  Copyright © 2017 Recisio. All rights reserved.
//

import Foundation

extension Array where Element: NSKeyValueObservation {

    public mutating func invalidateAll() {
        forEach {
            $0.invalidate()
        }
        removeAll()
    }

}
