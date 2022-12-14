//
//  Location.swift
//  No Fear List
//
//  Created by Timi on 12/12/22.


import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var description: String
    let latitude: Double
    let longitude: Double
    
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
   
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Where King Charles lives with his dorgis.", latitude: 51.501, longitude: -0.141)
   
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
        
        
    }
}
