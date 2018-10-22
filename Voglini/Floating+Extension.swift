//
//  CGFloat+Extension.swift
//  Voglini
//
//  Created by Antonios Mavrelos on 11/10/2018.
//  Copyright © 2018 Antonios Mavrelos. All rights reserved.
//

import CoreGraphics

//extension CGFloat {
//    var toRadians: CGFloat { return self * .pi / 180 }
//    var toDegrees: CGFloat { return self * 180 / .pi }
//}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
