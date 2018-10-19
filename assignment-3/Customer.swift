//
//  Customer.swift
//  assignment-1
//
//  Created by Tripp,Jacob on 9/25/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import MapKit

struct Customer {
    var name    : String?
    var email   : String?
    var street  : String?
    var city    : String?
    var state   : String?
    var zip     : String?
    var id      : String?
    var location : CLLocationCoordinate2D?
    var formattedAddress : String?
    
    init(_ data: [String: Any]) {
        self.name   = data["Name"] as? String
        self.email  = data["Email__c"] as? String
        self.street = data["Address__c"] as? String
        self.city   = data["City__c"] as? String
        self.state  = data["State__c"] as? String
        // dumb work around for SF, which was possibly broken in Winter 2019
        // if you can convert to an optional int and it's greater than 0,
        // convert to a string
        // else, just save it as an optional string
        if let zval = data["Zip__c"] as? Int, zval > 0 {
            self.zip = String(zval)
        } else {
            self.zip  = data["Zip__c"] as? String
        }
        self.id     = data["Id"] as? String
        self.formattedAddress = buildAddress()
    }
    
    /// returns Bool of whether current data is equivalent to a passed Customer object.
    static func ==(left: Customer, right: Customer) -> Bool {
        return left.name == right.name &&
                left.email == right.email &&
                left.street == right.street &&
                left.city == right.city &&
                left.state == right.state &&
                left.zip == right.zip
    }
    
    func asDictionary() -> [String:Any] {
        var data = [String:Any]()
        data["Name"] = self.name
        data["Email__c"] = self.email ?? ""
        data["Address__c"] = self.street ?? ""
        data["City__c"] = self.city ?? ""
        data["State__c"] = self.state ?? ""
        data["Zip__c"] = self.zip ?? ""
        return data
    }
    
    /// Returns formatted address using street, city, state, zip.
    /// Address used for obtaining coordinates with Apple geocoder.
    func buildAddress() -> String {
        var address : String = ""
        if self.street != nil {
            address += "\(self.street ?? "")"
        }
        if self.city != nil {
            address += ", \(self.city ?? "")"
        }
        if self.state != nil {
            address += ", \(self.state ?? "")"
        }
        if self.zip != nil {
            address += " \(self.zip ?? "")"
        }
        return address
    }
}
