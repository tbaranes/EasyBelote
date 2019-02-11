//
//  HighlightableView.swift
//  EasyBelote iOS
//
//  Created by Tom Baranes on 13/02/2019.
//  Copyright © 2019 barboteur. All rights reserved.
//

import UIKit

class HighlightableView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.forEach {
            $0.alpha = 0.5
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.forEach {
            $0.alpha = 1
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        subviews.forEach {
            $0.alpha = 1
        }
    }

}
