//
//  MapKit+Example.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import Foundation

final class Ticket {
    private(set) var isCancelled = false
    
    func cancel() {
        isCancelled = true
    }
}
