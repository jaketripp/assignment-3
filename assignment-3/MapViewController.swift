//
//  MapViewController.swift
//  MapKitTest
//
//  Created by Tripp,Jacob on 10/13/18.
//  Copyright © 2018 Tripp,Jacob. All rights reserved.
//

//    let goldenGateLocation = CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)
//    let statueOfLibertyLocation = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0445)
//    let kremlinLocation = CLLocationCoordinate2D(latitude: 55.7520, longitude: 37.6175)
//
//    let goldenGatePin = CustomPin(title: "Golden Gate Bridge", subtitle: "The Golden Gate Bridge is a suspension bridge spanning the Golden Gate, the one-mile-wide strait connecting San Francisco Bay and the Pacific Ocean.", coordinate: goldenGateLocation)
//    let statueOfLibertyPin = CustomPin(title: "State of Liberty", subtitle: "The Statue of Liberty is a colossal neoclassical sculpture on Liberty Island in New York Harbor in New York City, in the United States.", coordinate: statueOfLibertyLocation)
//    let kremlinPin = CustomPin(title: "Moscow Kremlin", subtitle: "The Moscow Kremlin, or simply the Kremlin, is a fortified complex at the heart of Moscow, overlooking the Moskva River to the south, Saint Basil's Cathedral and Red Square to the east, and the Alexander Garden to the west.", coordinate: kremlinLocation)
//
//    self.mapView.addAnnotation(goldenGatePin)
//    self.mapView.addAnnotation(statueOfLibertyPin)
//    self.mapView.addAnnotation(kremlinPin)

import UIKit
import MapKit

/// Custom pin class that adheres to the MKAnnotation protocol to have a custom pin.
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

/// Region struct that holds the necessary info to create a region (center coordinate and span)
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
    var mapPins : [CustomPin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geoCode(customers: customers) { results in
            print("Got back \(results.count) results")
            self.centerAndZoom()
        }
        
        self.mapView.delegate = self
    }
    
    func geoCode(customers: [Customer], resultCustomers: [Customer] = [], completion: @escaping ([Customer]) -> Void ) {
        guard let address = customers.first?.formattedAddress else {
            completion(resultCustomers)
            return
        }
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            
            var updatedResults = resultCustomers
            
            if let placemark = placemarks?.first {
                var customerWithLocation = customers[0]
                customerWithLocation.location = placemark.location?.coordinate
                self.createMapPin(for: customerWithLocation)
                updatedResults.append(customerWithLocation)
            }
            
            let remainingCustomers = Array(customers[1..<customers.count])
            
            self.geoCode(customers: remainingCustomers, resultCustomers: updatedResults, completion: completion)
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
        
        if let name = customer.name, let coordinates = customer.location, let address = customer.formattedAddress {
            let customPin = CustomPin(title: name, subtitle: address, coordinate: coordinates)
            self.mapPins.append(customPin)
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
        // print("annotation title == \(String(describing: view.annotation?.title!))")
    }
    
    /// Sets the optimal center point and zoom level
    func centerAndZoom() {
        let points = self.mapView.annotations.map({ $0.coordinate })
        let regionInfo = self.getRegionInfo(points: points, insetX: 6, insetY: 16)
        let center = CLLocationCoordinate2DMake(regionInfo.latitude, regionInfo.longitude)
        let span = MKCoordinateSpan(latitudeDelta: regionInfo.latitudeDelta, longitudeDelta: regionInfo.longitudeDelta)
        let region = MKCoordinateRegionMake(center, span)
        self.mapView.setRegion(region, animated: true)
    }
    
    /// Mathematically calculates the optimal center and zoom based on an array of coordinates
    func getRegionInfo(points : [CLLocationCoordinate2D], insetX: Double? = 3, insetY: Double? = 3) -> Region {
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

        return Region(latitude: midX, longitude: midY, latitudeDelta: deltaX, longitudeDelta: deltaY)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

