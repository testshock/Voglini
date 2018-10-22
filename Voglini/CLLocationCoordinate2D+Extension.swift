//
//  CLLocationCoordinate2D+Extension.swift
//  Voglini
//
//  Created by Antonios Mavrelos on 16/10/2018.
//  Copyright © 2018 Antonios Mavrelos. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
