//
//  ViewController.swift
//  MapKitTest
//
//  Created by Tripp,Jacob on 10/13/18.
//  Copyright © 2018 Tripp,Jacob. All rights reserved.
//

import UIKit
import MapKit

class CustomPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Golden Gate Bridge
        let goldenGateLocation = CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)
        let statueOfLibertyLocation = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445)
        let kremlinLocation = CLLocationCoordinate2D(latitude: 55.7520, longitude: 37.6175)
        let centerLat = (goldenGateLocation.latitude + statueOfLibertyLocation.latitude) / 2
        let centerLong = (goldenGateLocation.longitude + statueOfLibertyLocation.longitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        //        // low values means zoomed out
        let span = MKCoordinateSpan(latitudeDelta:
            3, longitudeDelta: 50)
        let region = MKCoordinateRegion(center: center, span: span)
        // how are we going to set the region and span for tons of customers
        // sort the customers by lat, then average it? or maybe do it based statisically?
        // show zoomed into Texas if there are 50 texas people and one californian?
        // for span, we have to figure out some relation
        // if we just want it to get the "most bang for buck"
        // then calculate the center
        // either get the
        // same with long
        self.mapView.setRegion(region, animated: true)
        
        let goldenGatePin = CustomPin(title: "Golden Gate Bridge", subtitle: "The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean.", coordinate: goldenGateLocation)
        let statueOfLibertyPin = CustomPin(title: "State of Liberty", subtitle: "The Statue of Liberty is a colossal neoclassical sculpture on Liberty Island in New York Harbor in New York City, in the United States.", coordinate: statueOfLibertyLocation)
        let kremlinPin = CustomPin(title: "Moscow Kremlin", subtitle: "The Moscow Kremlin, or simply the Kremlin, is a fortified complex at the heart of Moscow, overlooking the Moskva River to the south, Saint Basil's Cathedral and Red Square to the east, and the Alexander Garden to the west.", coordinate: kremlinLocation)
        
        self.mapView.addAnnotation(goldenGatePin)
        self.mapView.addAnnotation(statueOfLibertyPin)
        self.mapView.addAnnotation(kremlinPin)
        self.mapView.delegate = self
        //        self.mapView.layoutMargins = UIEdgeInsetsMake(40, 40, 40, 40)
        //        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        //        mapView.camera.altitude *= 1.4
        //        zoomToFitMapAnnotations(myMapView: self.mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        annotationView.image = UIImage(named: "pin")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //        print("annotation title == \(String(describing: view.annotation?.title!))")
    }
    
    func zoomToFitMapAnnotations(myMapView:MKMapView)
    {
        if(myMapView.annotations.count == 0)
        {
            return
        }
        
        
        var topLeftCoord = CLLocationCoordinate2D.init(latitude: -90, longitude: 180)
        
        
        var bottomRightCoord = CLLocationCoordinate2D.init(latitude: 90, longitude: -180)
        
        
        for i in 0..<myMapView.annotations.count
        {
            let annotation = myMapView.annotations[i]
            
            // get the absolute smallest longitude
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            // get the absolute biggest latitude
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            
            // get the absolute biggest longitude
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
            // get the absolute smallest latitude
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
        }
        
        
        let resd = CLLocationCoordinate2D.init(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
        
        let span = MKCoordinateSpan.init(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3, longitudeDelta: fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3)
        
        print(resd)
        var region = MKCoordinateRegion.init(center: resd, span: span);
        
        
        
        region = myMapView.regionThatFits(region)
        
        myMapView.setRegion(region, animated: true)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

