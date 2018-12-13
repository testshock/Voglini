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

class Polyline: MKPolyline {
    var color: UIColor?
}

class InterestingAnnotation:NSObject,MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: POIType
    var sound: String?
    var volume: Float?
    var distance: Double?
    var angle: Double?
    var distLine: Polyline!
    var selected: Bool
    init(_ latitude:CLLocationDegrees,_ longitude:CLLocationDegrees,title:String,subtitle:String,type:POIType, sound: String, volume: Float){
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.sound = sound
        self.volume = volume
        self.distance = -1.0
        self.angle = 0
        self.selected = false
    }
}

class InterestingAnnotations: NSObject {
    var pois:[InterestingAnnotation]
    var mapView: MKMapView?

    
    override init(){
        pois = [InterestingAnnotation(39.620759, 19.915563, title: "Eisodos aulis", subtitle:"spot 1", type: .game, sound: "500Hz_dBFS", volume: 0.0)]
        pois += [InterestingAnnotation(39.620964, 19.915672, title: "Dromos", subtitle:"spot 2", type: .game, sound: "1000Hz_dBFS", volume: 0.0)]
        pois += [InterestingAnnotation(39.620679, 19.915144, title: "Kentro aulis", subtitle:"spot 3", type: .game, sound: "2000Hz_dBFS", volume: 0.0)]
        pois += [InterestingAnnotation(39.621944, 19.917390, title: "Sarocco", subtitle:"spot 4", type: .game, sound: "2000Hz_dBFS", volume: 0.0)]
        pois += [InterestingAnnotation(39.621793, 19.918034, title: "Sarocco Center", subtitle:"spot 5", type: .game, sound: "2000Hz_dBFS", volume: 0.0)]

    
    }
    
    func setMapView(aMapView: MKMapView!){
        self.mapView = aMapView
    }
    
    
    func drawLine(poi: InterestingAnnotation, locValue: CLLocation){
    
        if poi.distLine != nil {
            self.mapView?.removeOverlay(poi.distLine)
        }
        

        //Create points for the line
        let lineVertices:[CLLocationCoordinate2D] = [(poi.coordinate) , (locValue.coordinate)]
        poi.distLine = Polyline(coordinates:lineVertices, count: 2)
        
        if poi.selected {
            poi.distLine.color = .blue
        } else{
            poi.distLine.color = .black
            
        }
        //Add an overlay, this will be drawn in renderFor
        self.mapView?.addOverlay(poi.distLine)
    }
    
    func deselectAll( ){
        for poi in pois{
            poi.selected = false
        }
    
    }
    
    
    func updateLoc(locValue: CLLocation){
        for poi in pois{
            let POILocation = poi.coordinate
            let currentLocation2D = locValue.coordinate
            let distanceInMeters = currentLocation2D.distance(from: (POILocation))
            poi.distance = distanceInMeters
            poi.angle = 0
            drawLine(poi: poi , locValue: locValue)
            if distanceInMeters < 100{
                poi.volume = Float((100-distanceInMeters)/100)
            }
            else {
            poi.volume = 0
            }
        }
    }
    
}
