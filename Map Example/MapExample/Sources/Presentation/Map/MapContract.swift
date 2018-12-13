//
//  MapContract.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import UIKit
import CoreLocation

protocol MapPresentable: AnyObject {
    func didTapOnMap(coordinate: CLLocationCoordinate2D)
}

struct MapViewableItem {
    typealias Identifier = UUID
    
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
}

struct MapViewableDecoration {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
}

protocol MapViewable: AnyObject {
    func addItem(_ item: MapViewableItem, withIdentifier identifier: MapViewableItem.Identifier)
    func removeItem(withIdentifier identifier: MapViewableItem.Identifier)
    
    func showDecoration(_ decoration: MapViewableDecoration, scrollingToItemsWithIdentifiers identifiers: Set<MapViewableItem.Identifier>)
    func hideDecoration(then completion: @escaping (Bool) -> Void)
    
    func enableMapInteraction()
    func disableMapInteraction()
}
