//
//  InterestingAnnotation.swift
//  Voglini
//
//  Created by Antonios Mavrelos on 11/10/2018.
//  Copyright © 2018 Antonios Mavrelos. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum POIType {
    case drink
    case food
    case game
}

class InterestingAnnotation:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: POIType
    init(_ latitude:CLLocationDegrees,_ longitude:CLLocationDegrees,title:String,subtitle:String,type:POIType){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}

class InterestingAnnotations: NSObject {
    var pois:[InterestingAnnotation]
    
    override init(){
        //build an array of pizza loactions literally
        pois = [InterestingAnnotation(39.620759, 19.915563, title: "Eisodos aulis", subtitle:"spot 1", type: .game)]
        pois += [InterestingAnnotation(39.620964, 19.915672, title: "Dromos", subtitle:"spot 2", type: .game)]
        pois += [InterestingAnnotation(39.620679, 19.915144, title: "Kentro aulis", subtitle:"spot 3", type: .game)]
    }
}
