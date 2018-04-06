//
//  Extensions.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation

extension Array where Element == Player {
    
    func start() {
        for i in self {
            i.start()
        }
    }
    
}
