//
//  Map.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation
import UIKit

class Map: UIView {
    
    let pointSize: Int = 10
    
    let cellSpacing: Int = 0
    
    var roads: [Road] = [Road]()
    var connections: [CAShapeLayer] = [CAShapeLayer]()
    
    var enabledColor: UIColor = UIColor.blue
    var disabledColor: UIColor = UIColor.red
    
    var trucks: [Truck] = [Truck]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(displayP3Red: 0.396, green: 0.745, blue: 0.478, alpha: 1.0)
    }
    
    
    func setUpPlayers(count: Int) {
        let truckSize: CGSize = CGSize.init(width: CELL_SIZE - 10, height: CELL_SIZE - 10)
        
        for i in 0...count - 1 {
            trucks.append(Truck.init())
            if i == 0 {
                trucks[i].contents = UIImage.init(named: "car1.png")!.cgImage
            } else if i == 1 {
                trucks[i].contents = UIImage.init(named: "car2.png")!.cgImage
            } else if i == 2 {
                trucks[i].contents = UIImage.init(named: "car3.png")!.cgImage
            } else if i == 3 {
                trucks[i].contents = UIImage.init(named: "car4.png")!.cgImage
            } else if i == 4 {
                trucks[i].contents = UIImage.init(named: "car5.png")!.cgImage
            } else {
                trucks[i].contents = UIImage.init(named: "car5.png")!.cgImage
            }
            trucks[i].contentsGravity = kCAGravityResizeAspect
            trucks[i].frame = CGRect.init(origin: CGPoint.init(x: bounds.width * 2, y: bounds.height * 2), size: truckSize)
            
            layer.addSublayer(trucks[i])
        }
    }
    
    func updatePoint(color: UIColor, coordinate: Coordinate, connections: [Connection], enabled: Bool, permanent: Bool) {
        self.drawPoint(coordinate: coordinate, connections: connections, enabled: enabled, permanent: permanent)
        if let road = self.node(at: coordinate) {
            road.performTransition(color: color)
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPoint(coordinate: Coordinate, connections: [Connection], enabled: Bool, permanent: Bool) {
        if let node: Road = node(at: coordinate) {
            node.enabled = enabled
            node.permanent = permanent
            if enabled {
                node.setTexture(connections: connections)
            } else {
                if permanent {
                    node.imageView.image = UIImage.init(named: "tileSand1")
                } else {
                    node.imageView.image = UIImage.init(named: "grass")
                }
            }

        } else {
            let road: Road = Road.init(coordinate: coordinate)
            if enabled {
                road.setTexture(connections: connections)
            } else {
                if permanent {
                    road.imageView.image = UIImage.init(named: "tileSand1")
                } else {
                    road.imageView.image = UIImage.init(named: "grass")
                }
            }
            
            let xPos: CGFloat = CGFloat((coordinate.x * Int(CELL_SIZE) - Int(CELL_SIZE / 2)))
            let yPos: CGFloat = CGFloat((coordinate.y * Int(CELL_SIZE) - Int(CELL_SIZE / 2)))
            
            road.frame = CGRect.init(x: xPos, y: yPos, width: CGFloat(CELL_SIZE), height: CGFloat(CELL_SIZE))
            
            self.roads.append(road)
            self.addSubview(self.roads.last!)
        }
    }
    
    
    
    
    
    func node(at coordinate: Coordinate) -> Road? {
        for i in self.roads {
            if i.coordinate == coordinate {
                return i
            }
        }
        
        return nil
    }
    
    func drawConnection(from: Coordinate, to: Coordinate, color: UIColor) {
        let line: CAShapeLayer = CAShapeLayer.init()
        line.strokeColor = color.cgColor
        line.lineWidth = 2.0
        line.path = self.path(from: from, to: to).cgPath
        connections.append(line)
        //self.layer.addSublayer(connections.last!)
    }
    
    func drawPath(path: Path) {
        let nodes: [Node] = path.array.reversed()
        for i in 0...nodes.count - 1 {
            let nextNodeIndex: Int = i + 1
            if nextNodeIndex > nodes.count - 1 {
                break
            }
            
            let nextNode: Node = nodes[nextNodeIndex]
            if nextNode.connection(for: nodes[i]) != nil {
                self.drawConnection(from: nodes[i].coordinate, to: nextNode.coordinate, color: UIColor.red)
            }
            
        }
    }
    
    
    func traversePath(index: Int, path: Path, color: UIColor, completion: @escaping (() -> ())) {
        
        let truckIndex: Int = index
        
        if trucks[truckIndex].animation(forKey: "move") != nil {
            return
        }
        layer.addSublayer(trucks[truckIndex])

        let nodes: [Node] = path.array.reversed()
        let path: UIBezierPath = UIBezierPath.init()
        path.lineJoinStyle = .round
        path.move(to: CGPoint.init(x: nodes[0].coordinate.x * Int(CELL_SIZE), y: nodes[0].coordinate.y * Int(CELL_SIZE)))
        
        var movementDuration: Double = TRAVERSAL_TIME
        movementDuration += TRAVERSAL_TIME
        
        for i in 0...nodes.count - 1 {
            let nextNodeIndex: Int = i + 1
            if nextNodeIndex > nodes.count - 1 {
                
                break
            }
            
            let nextNode: Node = nodes[nextNodeIndex]
            
            if let connection = nextNode.connection(for: nodes[i]) {
                movementDuration += TRAVERSAL_TIME
                
                path.addLine(to: CGPoint.init(x: nextNode.coordinate.x * Int(CELL_SIZE), y: nextNode.coordinate.y * Int(CELL_SIZE)))
            }
            
        }
        
        movementDuration += TRAVERSAL_TIME
        
        let keyframe: CAKeyframeAnimation = CAKeyframeAnimation.init(keyPath: "position")
        keyframe.duration = movementDuration
        keyframe.rotationMode = kCAAnimationRotateAuto
        
        keyframe.path = path.cgPath
        keyframe.isRemovedOnCompletion = true
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock {
            completion()
        }
        
        
        trucks[truckIndex].add(keyframe, forKey: "move")
        
        CATransaction.commit()
    }
    
    private func dirContains(directions: [Direction], contains: [Direction]) -> Bool {
        var isValid: Bool = true
        
        for i in contains {
            if !directions.contains(i) {
                isValid = false
            }
        }
        
        return isValid
    }
    
    func determinePlayerCoordinate(coordinate: Coordinate) -> CGPoint {
        return CGPoint.init(x: CGFloat(coordinate.x) * CELL_SIZE  - (CELL_SIZE / 2), y: CGFloat(coordinate.y) * CELL_SIZE  - (CELL_SIZE / 2))
        
        if coordinate.x == 0 {
            return CGPoint.init(x: -CELL_SIZE, y: CGFloat(coordinate.y) * CELL_SIZE)
        } else if coordinate.y == 0 {
            return CGPoint.init(x: CGFloat(coordinate.x) * CELL_SIZE, y: -CELL_SIZE)
        } else if coordinate.x == Int(BOARD_WIDTH) {
            return CGPoint.init(x: (BOARD_WIDTH + 1) * CELL_SIZE, y: CGFloat(coordinate.y) * CELL_SIZE)
        } else if coordinate.y == Int(BOARD_HEIGHT) {
            return CGPoint.init(x: CGFloat(coordinate.x) * CELL_SIZE, y: (BOARD_WIDTH + 1) * CELL_SIZE)
        }
        
        return CGPoint.zero
    }
    
    func determinePlayerDirection(coordinate: Coordinate) -> Direction {
        if coordinate.x == 0 {
            return .east
        } else if coordinate.y == 0 {
            return .south
        } else if coordinate.x == Int(BOARD_WIDTH) {
            return .west
        } else if coordinate.y == Int(BOARD_HEIGHT) {
            return .north
        }
        
        return .north
    }
    
    func path(from: Coordinate, to: Coordinate) -> UIBezierPath {
        let path: UIBezierPath = UIBezierPath.init()
        path.move(to: CGPoint.init(x: from.x * Int(CELL_SIZE), y: from.y * Int(CELL_SIZE)))
        path.addLine(to: CGPoint.init(x: to.x * Int(CELL_SIZE), y: to.y * Int(CELL_SIZE)))
        return path
    }
    
}
