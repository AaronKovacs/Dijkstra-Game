//
//  Route.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

struct Route: Equatable {
    var start: Coordinate
    var end: Coordinate
    var color: UIColor
    
    init(start: Coordinate, end: Coordinate) {
        self.start = start
        self.end = end
        self.color = UIColor.blue
    }
    
    init(start: Coordinate, end: Coordinate, color: UIColor) {
        self.start = start
        self.end = end
        self.color = color
    }
    
    static func ==(lhs: Route, rhs: Route) -> Bool {
        
        if lhs.start == rhs.start {
            return true
        }
        
        if lhs.start == rhs.end {
            return true
        }
        
        if lhs.end == rhs.end {
            return true
        }
        
        if lhs.end == rhs.start {
            return true
        }
        
        return false
    }
}
