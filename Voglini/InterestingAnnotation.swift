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
        pois = [InterestingAnnotation(37.98038, 23.72399, title: "Telis", subtitle:"Mprizolakia", type: .food)]
        pois += [InterestingAnnotation(37.9751, 23.7337, title: "Beer", subtitle:"Beer for all", type: .drink)]
        pois += [InterestingAnnotation(37.97586, 23.72851, title: "Escape room", subtitle:"Mind? Game", type: .game)]
    }
}
