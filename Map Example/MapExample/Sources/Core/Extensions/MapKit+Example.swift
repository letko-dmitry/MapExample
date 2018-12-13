//
//  MapKit+Example.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import MapKit

extension MKMapRect {
    init(region: MKCoordinateRegion) {
        let topLeftCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta / 2),
                                                       longitude: region.center.longitude - (region.span.longitudeDelta / 2))
        let bottomRightCoordinate = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta / 2),
                                                           longitude: region.center.longitude + (region.span.longitudeDelta / 2))
        
        let topLeft = MKMapPoint(topLeftCoordinate)
        let bottomRight = MKMapPoint(bottomRightCoordinate)
        
        self.init(origin: MKMapPoint(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y)),
                  size: MKMapSize(width: abs(topLeft.x - bottomRight.x), height: abs(topLeft.y - bottomRight.y)))
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
