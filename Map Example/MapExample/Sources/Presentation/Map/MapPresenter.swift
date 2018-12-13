//
//  MapPresenter.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import Foundation
import CoreLocation

final class MapPresenter {
    private var startItem: MapItem?
    private var endItem: MapItem?
    
    weak var view: MapViewable?
}

// MARK: - MapPresentable
extension MapPresenter: MapPresentable {
    func didTapOnMap(coordinate: CLLocationCoordinate2D) {
        switch (startItem, endItem) {
        case (.none, .none):
            let startItem = MapItem(coordinate: coordinate)
            let startViewableItem = MapViewableItem(coordinate: coordinate, color: .red)
            
            self.startItem = startItem
            
            view?.addItem(startViewableItem, withIdentifier: startItem.identifier)
            
        case let (.some(startItem), .none):
            if startItem.coordinate != coordinate {
                let endItem = MapItem(coordinate: coordinate)
                let endViewableItem = MapViewableItem(coordinate: coordinate, color: .blue)
                let decoration = MapViewableDecoration(startCoordinate: startItem.coordinate,
                                                       endCoordinate: endItem.coordinate)
                
                self.endItem = endItem
                
                view?.addItem(endViewableItem, withIdentifier: endItem.identifier)
                
                view?.disableMapInteraction()
                view?.showDecoration(decoration, scrollingToItemsWithIdentifiers: [startItem.identifier, endItem.identifier])
            } else {
                self.startItem = nil
                
                view?.removeItem(withIdentifier: startItem.identifier)
            }
            
        case let (.some(startItem), .some(endItem)):
            self.startItem = nil
            self.endItem = nil
            
            view?.hideDecoration { _ in
                self.view?.enableMapInteraction()
                
                self.view?.removeItem(withIdentifier: startItem.identifier)
                self.view?.removeItem(withIdentifier: endItem.identifier)
            }
            
        case (.none, .some):
            assertionFailure("Unexpected state")
        }
    }
}

// MARK: - MapItem
private struct MapItem {
    let identifier = UUID()
    let coordinate: CLLocationCoordinate2D
}
