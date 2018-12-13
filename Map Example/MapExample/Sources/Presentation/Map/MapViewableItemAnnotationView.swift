//
//  MapViewableItemView.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import UIKit
import MapKit

final class MapViewableItemAnnotationView: UIView {
    let imageView = UIImageView(image: R.image.mapPinTemplate())
    var coordinate = CLLocationCoordinate2D()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.center.x = bounds.midX
        imageView.center.y = bounds.midY - imageView.bounds.size.height / 2
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: max(size.width, imageView.bounds.width),
                      height: max(size.width, imageView.bounds.height * 2))
    }
}
