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
import CoreMotion

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var accelLabel: UILabel!
    @IBOutlet weak var gyroLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var targetHeadingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var audioPlayer: AVAudioPlayer!

    var timer: Timer!
    var distLine: MKPolyline!
    var distLineView: MKPolylineView!
    
    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    
    var currentLocation: CLLocationCoordinate2D!
    
    let initialAnnotations = InterestingAnnotations()
    var onceinalifetaime = 0
    
    //For test purposes lets say that we only need 2 POIs
    let maxPOIcount = 2;
    
    let poiLocations: Set<CLLocation> = [CLLocation(latitude: 37.97534, longitude: 23.7363),CLLocation(latitude: 37.98407,longitude: 23.72802)];

    var touchedPOI: InterestingAnnotation?
    
    var angleToTargetInDegrees: Double = 0.0
    

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialAnnotations.setMapView(aMapView: self.mapView)


        /*do {
            if let fileURL = Bundle.main.path(forResource: "sounds/500Hz_dBFS", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
                audioPlayer?.volume = 0.5
                audioPlayer?.delegate = self
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }*/
        //

        GSAudio.sharedInstance.playSounds(soundFileNames: ["2000Hz_dBFS", "1000Hz_dBFS", "500Hz_dBFS"], startVolume: [0, 0.2, 0.1])

        
        
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 5;
            locationManager.startUpdatingHeading();
            print ("heading available")
        }
        

        
        // Make sure the accelerometer hardware is available.
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 20.0  // 20 Hz
            motionManager.gyroUpdateInterval = 1.0 / 20.0  // 20 Hz
            motionManager.startAccelerometerUpdates()
            if (motionManager.isGyroAvailable){
                motionManager.startGyroUpdates()
            }
            // Configure a timer to fetch the data.
            timer = Timer(fire: Date(), interval: (1.0/20.0),
                        repeats: true, block: { (timer) in
                    // Get the accelerometer data.
                     if let data = self.motionManager.accelerometerData {
                            let x = data.acceleration.x
                            let y = data.acceleration.y
                            let z = data.acceleration.z
                                    
                        self.accelLabel.text = String(format:"[%.2f %.2f %.2f] ", x, y, z )
                    }
                    if let data = self.motionManager.gyroData {
                            let x = data.rotationRate.z
                            let y = data.rotationRate.y
                            let z = data.rotationRate.z
                                
                            self.gyroLabel.text = String(format:"[%.2f %.2f %.2f] ", x, y, z )
                    }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
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
        //print("\(distanceLabel.isHidden)")
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
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        self.currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: self.currentLocation, span: span)
        
        initialAnnotations.updateLoc(locValue: location)
        
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
        annotation.subtitle = String(format:"%f", annotation.distance ?? 0)
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
        //drawLineToPOI()

        updateHUD()
        UIView.animate(withDuration: 0.5) {
            let angle = newHeading.trueHeading.degreesToRadians //trueHeading.toRadians // convert from degrees to radians
            //self.mapView.transform = CGAffineTransform(rotationAngle: CGFloat(angle)) // rotate the picture
            self.headingLabel.text = String(format:"%f", angle)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected view \(String(describing: view.annotation?.title ?? "Annotation with no title?"))")
        touchedPOI = (view.annotation as! InterestingAnnotation)
    
        initialAnnotations.deselectAll()
        touchedPOI!.selected = true
        //drawLineToPOI()
        updateHUD()
    }
    
    /*
     Draw a line from current position (center of screen) to the selected POI
     This is called when user selects a POI. If the user selects another POI, delete old and create a new one
     
     TODO: When user touches map (not POI) and there is a line drawn, remove it
    */
    /*func drawLineToPOI(){
        //delete old line before draw new
        if self.distLine != nil {
            mapView.removeOverlay(distLine)
        }
        
        if touchedPOI == nil {
            return
        }
        
        //Create points for the line
        let lineVertices:[CLLocationCoordinate2D] = [(self.touchedPOI?.coordinate)! , (locationManager.location?.coordinate)!]
        //self.distLine = Polyline(coordinates:lineVertices, count: 2)

        //Add an overlay, this will be drawn in renderFor
        mapView.addOverlay(distLine)
    }*/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? Polyline {
            let distLineRenderer = MKPolylineRenderer(polyline: polyline)
            distLineRenderer.strokeColor = polyline.color
            distLineRenderer.lineWidth = 3.0
            distLineRenderer.alpha = 0.7
            distLineRenderer.lineDashPattern = [2, 7]
            return distLineRenderer
        }
        fatalError("Something wrong...Call Voglis to the rescue")

    }
}

