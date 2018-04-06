//
//  Connection.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

class Connection {
    public let to: Node
    public let weight: Int
    public var enabled: Bool = true
    public var direction: Direction = .north
    public init(to node: Node, weight: Int) {
        self.to = node
        self.weight = weight
    }
    
    public init(to node: Node, weight: Int, direction: Direction) {
        self.to = node
        self.weight = weight
        self.direction = direction
    }
}
