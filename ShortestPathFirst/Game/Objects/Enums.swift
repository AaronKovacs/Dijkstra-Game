//
//  Enums.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

enum Direction: Int {
    case north = 1
    case south = 2
    case west = 3
    case east = 4
    
    func opposite() -> Direction {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .west:
            return .east
        case .east:
            return .west
        }
    }
}

enum Interaction {
    case open
    case block
    case delete
}
