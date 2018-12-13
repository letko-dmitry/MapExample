//
//  MapViewableDecorationView.swift
//  MapExample
//
//  Created by Dmitry Letko on 13.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import UIKit

final class MapViewableDecorationView: UIView {
    private enum Options {
        static let animationDuration = 1.second
    }
    
    private enum Constants {
        static let linePathLayerAnimationKey = "linePathLayerAnimationKey"
        static let blinkingDotViewAnimationKey = "blinkingDotViewAnimationKey"
    }
    
    private let linePathLayer = CAShapeLayer()
    private let blinkingDotView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        blinkingDotView.bounds.size = CGSize(width: 8, height: 8)
        blinkingDotView.layer.cornerRadius = 4
        blinkingDotView.backgroundColor = .white
        
        addSubview(blinkingDotView)
        
        linePathLayer.lineWidth = 2
        linePathLayer.lineCap = .round
        linePathLayer.lineJoin = .round
        linePathLayer.fillColor = nil
        linePathLayer.strokeColor = UIColor.white.cgColor
        linePathLayer.strokeEnd = 0
        
        layer.addSublayer(linePathLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        linePathLayer.frame = bounds
    }
    
    func startAnimation(from fromPoint: CGPoint, to toPoint: CGPoint) {
        assert(fromPoint != toPoint, "The case is not expected")
        
        let path = UIBezierPath()
        path.move(to: fromPoint)
        path.addQuadCurve(to: toPoint, controlPoint: quadCurveControlPoint(from: fromPoint, to: toPoint))
        
        let linePathAnimation = CABasicAnimation(keyPath: String(forKeyPath: \CAShapeLayer.strokeEnd))
        linePathAnimation.fillMode = .forwards
        linePathAnimation.fromValue = 0
        linePathAnimation.toValue = 1
        linePathAnimation.duration = Options.animationDuration
        linePathAnimation.isRemovedOnCompletion = false
        
        linePathLayer.path = path.cgPath
        linePathLayer.add(linePathAnimation, forKey: Constants.linePathLayerAnimationKey)
        
        let blinkingDotAnimation = CAKeyframeAnimation(keyPath: String(forKeyPath: \CALayer.position))
        blinkingDotAnimation.fillMode = .forwards
        blinkingDotAnimation.path = path.cgPath
        blinkingDotAnimation.duration = Options.animationDuration
        blinkingDotAnimation.repeatCount = .greatestFiniteMagnitude
        blinkingDotAnimation.isRemovedOnCompletion = false
        
        blinkingDotView.layer.add(blinkingDotAnimation, forKey: Constants.blinkingDotViewAnimationKey)
    }
    
    func stopAnimation() {
        linePathLayer.removeAnimation(forKey: Constants.linePathLayerAnimationKey)
        blinkingDotView.layer.removeAnimation(forKey: Constants.blinkingDotViewAnimationKey)
    }
}

private func normalize(vector: CGPoint) -> CGPoint {
    assert(vector.x != 0 || vector.y != 0, "The case is not expected")
    
    let maxAbsValue = max(abs(vector.x), (vector.y))
    
    return CGPoint(x: vector.x / maxAbsValue, y: vector.y / maxAbsValue)
}

private func quadCurveControlPoint(from: CGPoint, to: CGPoint) -> CGPoint {
    assert(from != to, "The case is not expected")
    
    let direction = CGPoint(x: to.x - from.x, y: to.y - from.y)
    let vector = normalize(vector: direction)
    let length = sqrt(direction.x * direction.x + direction.y * direction.y)
    
    let midpoint = CGPoint(x: from.x + vector.x * length * 0.4,
                           y: from.y + vector.y * length * 0.4)
    let vectorToControl = normalize(vector: CGPoint(x: from.y - midpoint.y, y: midpoint.x - from.x))
    
    return CGPoint(x: midpoint.x + vectorToControl.x * length * 0.3,
                   y: midpoint.y + vectorToControl.y * length * 0.3)
}
