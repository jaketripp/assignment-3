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
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

struct Region {
    var latitude : Double
    var longitude : Double
    var latitudeDelta : Double
    var longitudeDelta : Double
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let geoCoder = CLGeocoder()
    
    var customers : [Customer]!
    var mapPins : [CustomPin]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Golden Gate Bridge
//        let goldenGateLocation = CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)
//        let statueOfLibertyLocation = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445)
//        let kremlinLocation = CLLocationCoordinate2D(latitude: 55.7520, longitude: 37.6175)
//
//        let goldenGatePin = CustomPin(title: "Golden Gate Bridge", subtitle: "The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean.", coordinate: goldenGateLocation)
//        let statueOfLibertyPin = CustomPin(title: "State of Liberty", subtitle: "The Statue of Liberty is a colossal neoclassical sculpture on Liberty Island in New York Harbor in New York City, in the United States.", coordinate: statueOfLibertyLocation)
//        let kremlinPin = CustomPin(title: "Moscow Kremlin", subtitle: "The Moscow Kremlin, or simply the Kremlin, is a fortified complex at the heart of Moscow, overlooking the Moskva River to the south, Saint Basil's Cathedral and Red Square to the east, and the Alexander Garden to the west.", coordinate: kremlinLocation)
//
//        self.mapView.addAnnotation(goldenGatePin)
//        self.mapView.addAnnotation(statueOfLibertyPin)
//        self.mapView.addAnnotation(kremlinPin)
        
        geoCode(customers: customers) { results in
            print("Got back \(results.count) results")
//            print(self.mapView.annotations)

        }
        print(self.mapView.annotations)
//        self.getCustomerLocations()
        self.mapView.delegate = self
    }
    
    func geoCode(customers: [Customer], results: [CLLocation] = [], completion: @escaping ([CLLocation]) -> Void ) {
        guard let address = customers.first?.formattedAddress else {
            completion(results)
            return
        }
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            
            var updatedResults = results
            
            if let placemark = placemarks?.first {
                var customerWithLocation = customers[0]
                customerWithLocation.location = placemark.location?.coordinate
                self.createMapPin(for: customerWithLocation)
                updatedResults.append(placemark.location!)
            }
            
            let remainingCustomers = Array(customers[1..<customers.count])
            
            self.geoCode(customers: remainingCustomers, results: updatedResults, completion: completion)
        }
    }
    
//    func getCustomerLocations() {
//        let geoCoder = CLGeocoder()
//        for customer in customers.dictionary.values {
//            geoCoder.geocodeAddressString(address) { (placemarks, error) in
//                guard
//                    let placemarks = placemarks,
//                    let location = placemarks.first?.location?.coordinate
//                    else {
//                        // handle no location found
//                        print("Error no location found")
//                        return
//                }
//                print(location)
//                if let id = customer.id {
//                    var customerWithLocation = customer
//                    customerWithLocation.location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//                    self.createMapPin(for: customerWithLocation)
//                    self.customers.dictionary[id] = customerWithLocation
//                }
//
//            }
//        }
//    }
    
    // given a customer, adds an annotation to the map
    func createMapPin(for customer: Customer) {
        
        if let name = customer.name, let coordinates = customer.location {
            let customPin = CustomPin(title: name, subtitle: "Something interesting goes here", coordinate: coordinates)
            mapPins.append(customPin)
            self.mapView.addAnnotation(customPin)
        }
        
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
    
    
    
//    func zoomToFitMapAnnotations(myMapView:MKMapView)
//    {
//        if(myMapView.annotations.count == 0)
//        {
//            return
//        }
//
//
//        var topLeftCoord = CLLocationCoordinate2D.init(latitude: -90, longitude: 180)
//
//
//        var bottomRightCoord = CLLocationCoordinate2D.init(latitude: 90, longitude: -180)
//
//
//        for i in 0..<myMapView.annotations.count
//        {
//            let annotation = myMapView.annotations[i]
//
//            // get the absolute smallest longitude
//            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
//            // get the absolute biggest latitude
//            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
//
//            // get the absolute biggest longitude
//            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
//            // get the absolute smallest latitude
//            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
//        }
//
//
//        let resd = CLLocationCoordinate2D.init(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
//
//        let span = MKCoordinateSpan.init(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3, longitudeDelta: fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3)
//
//        print(resd)
//        var region = MKCoordinateRegion.init(center: resd, span: span);
//
//
//
//        region = myMapView.regionThatFits(region)
//
//        myMapView.setRegion(region, animated: true)
//
//
//    }
    
    func getRegionInfo(points : [CLLocationCoordinate2D], insetX: Double?, insetY: Double?) -> Region {
        var minX = points[0].latitude
        var maxX = points[0].latitude
        var minY = points[0].longitude
        var maxY = points[0].longitude

        // calculate rect
        for point in points {
            minX = min(minX, point.latitude)
            maxX = max(maxX, point.latitude)
            minY = min(minY, point.longitude)
            maxY = max(maxY, point.longitude)
        }

        let midX = (minX + maxX) / 2
        let midY = (minY + maxY) / 2
//        let midPoint = [midX, midY];

        var deltaX = (maxX - minX)
        var deltaY = (maxY - minY)

        if let insetX = insetX {
            deltaX += insetX
        }

        if let insetY = insetY {
            deltaY += insetY
        }

//        var regionInfo =
//        regionInfo.latitude = midX
//        regionInfo.longitude = midY
//        regionInfo.latitudeDelta = deltaX
//        regionInfo.longitudeDelta = deltaY
//
//        return regionInfo
        return Region(latitude: midX, longitude: midY, latitudeDelta: deltaX, longitudeDelta: deltaY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

