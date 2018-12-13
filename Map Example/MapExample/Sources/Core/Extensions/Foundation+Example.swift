//
//  Foundation+Example.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import Foundation

extension Double {
    var second: TimeInterval { return self }
    var seconds: TimeInterval { return self }
    
    var millisecond: TimeInterval { return self / 1000 }
    var milliseconds: TimeInterval { return self / 1000 }
}

extension String {
    init<Root, Value>(forKeyPath keyPath: KeyPath<Root, Value>) {
        self = NSExpression(forKeyPath: keyPath).keyPath
    }
}
