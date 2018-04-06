//
//  Coordinate.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

struct Coordinate: Equatable {
    
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.x == rhs.x && lhs.y == rhs.y {
            return true
        }
        
        return false
    }
    
}
