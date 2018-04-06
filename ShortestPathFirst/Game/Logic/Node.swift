//
//  Node.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

class Node: NSObject {
    var visited = false
    var connections: [Connection] = []
    var passthroughAllowed: Bool = true
    var permanentlyDisabled: Bool = false
    var enabled: Bool = true {
        didSet {
            for i in self.connections {
                i.enabled = self.enabled
                i.to.enableConnections(enabled: self.enabled, for: self)
            }
        }
    }
    var coordinate: Coordinate = Coordinate.init(x: 0, y: 0)
    
    init(coordinate: Coordinate) {
        self.coordinate = coordinate
    }
    
    func addConnection(connection: Connection) {
        for i in self.connections {
            if i.to == connection.to {
                return
            }
        }
        connections.append(connection)
    }
    
    func connection(for node: Node) -> Connection? {
        for i in self.connections {
            if i.to == node {
                return i
            }
        }
        
        return nil
    }
    
    func enableConnections(enabled: Bool, for node: Node) {
        if !self.enabled {
            return
        }
        
        for i in self.connections {
            if i.to == node{
                i.enabled = enabled
            }
        }
        
    }
}
