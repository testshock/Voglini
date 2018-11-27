//
//  ViewController.swift
//  Voglini
//
//  Created by Antonios Mavrelos on 23/01/2018.
//  Copyright © 2018 Antonios Mavrelos. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation


class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var targetHeadingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var distLine: MKPolyline!
    var distLineView: MKPolylineView!
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    var currentLocation: CLLocationCoordinate2D!
    
    let initialAnnotations = InterestingAnnotations()
    var onceinalifetaime = 0
    
    //For test purposes lets say that we only need 2 POIs
    let maxPOIcount = 2;
    
    let poiLocations: Set<CLLocation> = [CLLocation(latitude: 37.97534, longitude: 23.7363),CLLocation(latitude: 37.98407,longitude: 23.72802)];

    var touchedPOI: MKAnnotation?
    
    var angleToTargetInDegrees: Double = 0.0
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       /*
        let path = Bundle.main.path(forResource: "beep.wav", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            //create your audioPlayer in your parent class as a property
            let audioPlayer = try AVFoundation.AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("couldn't load the file")
        }
        */
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 5;
            locationManager.startUpdatingHeading();
            print ("heading available")
        }
        
        
        setupMap()
        showPOIs()
        updateHUD()
    }
    
    func updateHUD(){
        showHeading()
        showTargetDistance()
        showTargetHeading()
    }
    /*
    
    */
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    
    func showTargetHeading(){
        if touchedPOI == nil {
            return
        }
        
        //let deltaY = (touchedPOI?.coordinate.longitude)! - currentLocation.longitude;
        //let deltaX = (touchedPOI?.coordinate.latitude)! - currentLocation.latitude;
        //self.angleToTargetInDegrees = atan(deltaY / deltaX) * 180 / Double.pi
        self.angleToTargetInDegrees = getBearingBetweenTwoPoints1(point1: currentLocation, point2: touchedPOI!.coordinate )
        
        
        targetHeadingLabel.text = "TH:\(self.angleToTargetInDegrees)"
    }
    
    /* Get the heading of the device.
     */
    func showHeading(){
        let angleNorth = locationManager.heading?.magneticHeading
        self.headingLabel.text = "Heading:\(angleNorth ?? 0)"
    }

    /* Get the distance Current location <-> POI
       If there is no POI selected, do not show the label
     */
    func showTargetDistance(){
        //Show hide distance label
        print("\(distanceLabel.isHidden)")
        if touchedPOI == nil {
            distanceLabel.isHidden = true
            targetHeadingLabel.isHidden = true
            return
        } else if touchedPOI != nil && distanceLabel.isHidden == true {
           distanceLabel.isHidden = false
           targetHeadingLabel.isHidden = false
        }
        
        // User selected a POI. Find distance

        let POILocation = touchedPOI?.coordinate
        let currentLocation2D = locationManager.location?.coordinate
        let distanceInMeters = currentLocation2D?.distance(from: (POILocation)!) ?? 0
        self.distanceLabel.text = String(format:"%f", distanceInMeters )

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func showCompass() {
        //setup Mapview. For now we only need compass
        mapView.showsCompass = false  // Hide built-in compass
        
        var compassButton = MKCompassButton(mapView:self.mapView)
        compassButton = MKCompassButton(mapView: mapView)   // Make a new compass
        compassButton.compassVisibility = .visible          // Make it visible
        
        mapView.addSubview(compassButton) // Add it to the view
        
        // Position it as required
        
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        compassButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -12).isActive = true
        compassButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 12).isActive = true
    }
    
    func setupMap() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self 
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.delegate = self
        showCompass()

        // add the annotations
        mapView.addAnnotations(initialAnnotations.pois)
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showPOIs(){
    
    }
    
    //Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self.currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: self.currentLocation, span: span)
        
        if onceinalifetaime == 0{
            mapView.setRegion(region, animated: true)
            onceinalifetaime = 1
        }
        
        self.mapView.showsUserLocation = true
        
        //Update HUD
        updateHUD()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? InterestingAnnotation else {return nil}
        var identifier = ""
        var color = UIColor.red
        switch annotation.type{
        case .drink:
            identifier = "Drink"
            color = .red
        case .food:
            identifier = "Food"
            color = .black
        case .game:
            identifier = "Game"
            color = .blue
        }
        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView.markerTintColor = color
        annotationView.glyphImage = UIImage(named: "Antony's Points")
        annotationView.glyphTintColor = .yellow
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        drawLineToPOI()

        updateHUD()
        UIView.animate(withDuration: 0.5) {
            let angle = newHeading.trueHeading.degreesToRadians //trueHeading.toRadians // convert from degrees to radians
            //self.mapView.transform = CGAffineTransform(rotationAngle: CGFloat(angle)) // rotate the picture
            self.headingLabel.text = String(format:"%f", angle)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected view \(String(describing: view.annotation?.title ?? "Annotation with no title?"))")
        touchedPOI = view.annotation
        drawLineToPOI()
        updateHUD()
    }
    
    /*
     Draw a line from current position (center of screen) to the selected POI
     This is called when user selects a POI. If the user selects another POI, delete old and create a new one
     
     TODO: When user touches map (not POI) and there is a line drawn, remove it
    */
    func drawLineToPOI(){
        //delete old line before draw new
        if self.distLine != nil {
            mapView.removeOverlay(distLine)
        }
        
        if touchedPOI == nil {
            return
        }
        
        //Create points for the line
        let lineVertices:[CLLocationCoordinate2D] = [(self.touchedPOI?.coordinate)! , (locationManager.location?.coordinate)!]
        self.distLine = MKPolyline(coordinates:lineVertices, count: 2)

        //Add an overlay, this will be drawn in renderFor
        mapView.addOverlay(distLine)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let distLineRenderer = MKPolylineRenderer(polyline: polyline)
            distLineRenderer.strokeColor = .cyan
            distLineRenderer.lineWidth = 3.0
            distLineRenderer.alpha = 0.7
            return distLineRenderer
        }
        fatalError("Something wrong...Call Voglis to the rescue")

    }
}

