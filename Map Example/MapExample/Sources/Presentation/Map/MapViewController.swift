//
//  MapViewController.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var overlayView: UIView!
    @IBOutlet private var decorationsView: UIView!
    @IBOutlet private var annotationsView: UIView!

    private var itemsByIdentifier: [MapViewableItem.Identifier: MapViewableItem] = [:]
    private var viewsByIdentifier: [MapViewableItem.Identifier: MapViewableItemAnnotationView] = [:]
    
    private var isRegionBeingChanged = false
    private var awaitRegionChangeFinishedCallbacks: [() -> Void] = []
    
    private var showDecorationAnimationTicket: Ticket?
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    var presenter: MapPresentable!
}

// MARK: - MapViewable
extension MapViewController: MapViewable {
    func addItem(_ item: MapViewableItem, withIdentifier identifier: MapViewableItem.Identifier) {
        itemsByIdentifier[identifier] = item

        let view = findOrAddAnnotationViewForItem(withIdentifier: identifier)
        view.imageView.tintColor = item.color
        view.coordinate = item.coordinate
        
        layoutAnnotationViews()
    }
    
    func removeItem(withIdentifier identifier: MapViewableItem.Identifier) {
        guard itemsByIdentifier.removeValue(forKey: identifier) != nil else { return }
        guard let view = viewsByIdentifier.removeValue(forKey: identifier) else { return }
        
        view.removeFromSuperview()
    }
    
    func showDecoration(_ decoration: MapViewableDecoration, scrollingToItemsWithIdentifiers identifiers: Set<MapViewableItem.Identifier>) {
        assert(!identifiers.isEmpty, "It's useless to pass an empty colection")
        assert(decoration.startCoordinate != decoration.endCoordinate, "The case is not expected")
        
        let ticket = issueNewShowDecorationAnimationTicket()
        
        UIView.animate(withDuration: 300.milliseconds, animations: {
            self.scrollToItems(withIdentifiers: identifiers, animated: true)
            self.darkenMap()
            self.hideDecoration()
        }, completion: { finished in
            guard finished else { return }
            guard !ticket.isCancelled else { return }
            
            self.awaitAnimatedRegionChangeFinished { [weak self] in
                guard !ticket.isCancelled else { return }
                
                self?.showDecoration(decoration)
            }
        })
    }
    
    func hideDecoration(then completion: @escaping (Bool) -> Void) {
        cancelShowDecorationAnimationTicket()
        
        UIView.animate(withDuration: 200.milliseconds, animations: {
            self.hideDecoration()
            self.lightenMap()
        }, completion: completion)
    }
    
    func disableMapInteraction() {
        mapView.isUserInteractionEnabled = false
    }
    
    func enableMapInteraction() {
        mapView.isUserInteractionEnabled = true
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        isRegionBeingChanged = true
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard isRegionBeingChanged else { return }
        
        isRegionBeingChanged = false
        
        awaitRegionChangeFinishedCallbacks.forEach { $0() }
        awaitRegionChangeFinishedCallbacks.removeAll()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        layoutAnnotationViews()
    }
}

// MARK: - private
private extension MapViewController {
    @IBAction func handleTapGestureOnContentView(_ sender: UIGestureRecognizer) {
        guard sender.state == .recognized else { return }
        
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
    
        presenter.didTapOnMap(coordinate: coordinate)
    }
}

// MARK: - private
private extension MapViewController {
    func findOrAddAnnotationViewForItem(withIdentifier identifier: MapViewableItem.Identifier) -> MapViewableItemAnnotationView {
        if let view = viewsByIdentifier[identifier] {
            return view
        }
        
        let view = MapViewableItemAnnotationView()
        view.sizeToFit()
        
        annotationsView.addSubview(view)
        
        viewsByIdentifier[identifier] = view
        
        return view
    }
    
    func layoutAnnotationViews() {
        viewsByIdentifier.values.forEach { view in
            view.center = mapView.convert(view.coordinate, toPointTo: annotationsView)
        }
    }
}

// MARK: - private
private extension MapViewController {
    func scrollToItems(withIdentifiers identifiers: Set<MapViewableItem.Identifier>, animated: Bool) {
        assert(!identifiers.isEmpty, "It's useless to pass an empty colection")
        
        let views: [MapViewableItemAnnotationView] = viewsByIdentifier.compactMap { key, value in identifiers.contains(key) ? value : nil }
        let viewsRect = views.reduce(CGRect.null) { rect, view in rect.union(view.frame) }
        let mapRect = MKMapRect(region: mapView.convert(viewsRect, toRegionFrom: annotationsView))
        let edgePadding = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
       
        mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: true)
    }
    
    func darkenMap() {
        overlayView.alpha = 1
    }
    
    func lightenMap() {
        overlayView.alpha = 0
    }
    
    func showDecoration(_ decoration: MapViewableDecoration) {
        let startPoint = mapView.convert(decoration.startCoordinate, toPointTo: decorationsView)
        let endPoint = mapView.convert(decoration.endCoordinate, toPointTo: decorationsView)
        
        let decorationRect = CGRect(x: min(startPoint.x, endPoint.x),
                                    y: min(startPoint.y, endPoint.y),
                                    width: max(startPoint.x, endPoint.x) - min(startPoint.x, endPoint.x),
                                    height: max(startPoint.y, endPoint.y) - min(startPoint.y, endPoint.y))
        let decorationView = MapViewableDecorationView(frame: decorationRect)
        
        decorationsView.addSubview(decorationView)
        
        decorationView.startAnimation(from: decorationView.convert(startPoint, from: decorationsView),
                                      to: decorationView.convert(endPoint, from: decorationsView))
    }
    
    func hideDecoration() {
        decorationsView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func issueNewShowDecorationAnimationTicket() -> Ticket {
        let ticket = Ticket()
        
        showDecorationAnimationTicket?.cancel()
        showDecorationAnimationTicket = ticket
        
        return ticket
    }
    
    func cancelShowDecorationAnimationTicket() {
        showDecorationAnimationTicket?.cancel()
        showDecorationAnimationTicket = nil
    }
    
    func awaitAnimatedRegionChangeFinished(then completion: @escaping () -> Void) {
        if !isRegionBeingChanged {
            completion()
        } else {
            awaitRegionChangeFinishedCallbacks.append(completion)
        }
    }
}
