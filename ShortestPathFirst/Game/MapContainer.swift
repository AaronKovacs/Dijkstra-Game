//
//  MapContainer.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation
import UIKit

class MapContainer: UIView, Drawable {
    
    var map: Map
    var mapBackground: UIView = {
        let viw: UIView = UIView.init()
        viw.backgroundColor = UIColor.init(displayP3Red: 0.396, green: 0.745, blue: 0.478, alpha: 1.0)
        viw.layer.cornerRadius = 24
        return viw
    }()
    
    var editType: UISegmentedControl = {
        let control: UISegmentedControl = UISegmentedControl.init()
        control.insertSegment(withTitle: "Block", at: 0, animated: false)
        control.insertSegment(withTitle: "Delete", at: 0, animated: false)
        control.insertSegment(withTitle: "Build", at: 0, animated: false)
        control.tintColor = UIColor.white
        control.selectedSegmentIndex = 0
        return control
    }()
    
    var border: CAShapeLayer!
    
    var gameManager: GameManager!
    var routes: [Route] = [Route]()
    
    var seekingInteraction: Bool = false
    var interactionType: Interaction = .open
    
    override init(frame: CGRect) {
        map = Map.init(frame: CGRect.init(x: frame.width / 2 - (BOARD_WIDTH * CELL_SIZE / 2), y: frame.height / 2 - (BOARD_HEIGHT * CELL_SIZE / 2), width: BOARD_WIDTH * CELL_SIZE, height: BOARD_HEIGHT * CELL_SIZE))
        super.init(frame: frame)
        addSubview(map)
        
        
        
        tintAdjustmentMode = .normal
        tintColor = UIColor.clear
        backgroundColor = UIColor.black
        
        gameManager = GameManager.init(delegate: self)
        
        //self.showPlayerBackgrounds(routes: self.routes)
        
        mapBackground.frame = map.frame.insetBy(dx: -32/*-CELL_SIZE * 1.5*/, dy: -32/*-CELL_SIZE * 1.5*/)
        insertSubview(mapBackground, at: 0)
        border = CAShapeLayer.init()
        border.strokeColor = UIColor(displayP3Red: 0.227, green: 0.467, blue: 0.282, alpha: 1.00).cgColor
        //border.borderWidth = 8.0
        border.lineWidth = 8.0
        border.fillColor = UIColor.clear.cgColor
        border.path = UIBezierPath.init(roundedRect: mapBackground.frame, cornerRadius: 24).cgPath
        layer.addSublayer(border)
        
        self.editType.addTarget(self, action: #selector(changeSelection), for: .valueChanged)
        addSubview(self.editType)
        self.editType.frame = CGRect.init(x: 16, y: map.frame.maxY + CELL_SIZE * 2 + 32, width: bounds.width - 32, height: 32)
    }
    
    func updatePoint(color: UIColor, coordinate: Coordinate, connections: [Connection], enabled: Bool, permanent: Bool) {
        self.map.updatePoint(color: color, coordinate: coordinate, connections: connections, enabled: enabled, permanent: permanent)
    }
    
    @objc func changeSelection() {
        switch editType.selectedSegmentIndex {
        case 0:
            self.interactionType = .open
        case 1:
            self.interactionType = .delete
        case 2:
            self.interactionType = .block
        default:
            break
        }
    }
    
    func showPlayers(routes: [Route]) {
        self.routes = routes
        map.setUpPlayers(count: routes.count)
        for i in routes {
            
            let point = self.determinePlayerCoordinate(coordinate: i.start)
            let fromRect: CGRect = CGRect.init(origin: point, size: CGSize.init(width: CELL_SIZE, height: CELL_SIZE))
            let from: FromView = FromView.init(frame: self.convert(fromRect, from: map))
            if i.color == UIColor.blue {
                from.image = UIImage.init(cgImage: UIImage.init(named: "senderBlue")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.start))
            } else {
                from.image = UIImage.init(cgImage: UIImage.init(named: "Sender")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.start))
            }
            addSubview(from)
            
            let toRect: CGRect = CGRect.init(origin: self.determinePlayerCoordinate(coordinate: i.end), size: CGSize.init(width: CELL_SIZE, height: CELL_SIZE))
            let to: ToView = ToView.init(frame: self.convert(toRect, from: map))
            if i.color == UIColor.blue {
                to.image = UIImage.init(cgImage: UIImage.init(named: "recBlue")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.end))
            } else {
                to.image = UIImage.init(cgImage: UIImage.init(named: "rec")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.end))
            }
            addSubview(to)
            
        }
        
        
    }
    
    func removeSelf() {
        gameManager.removeAllPlayers()
    }
    
    func showPlayerBackgrounds(routes: [Route]) {
        for i in routes {
            
            let point = self.determinePlayerCoordinate(coordinate: i.start)
            let fromRect: CGRect = CGRect.init(origin: point, size: CGSize.init(width: CELL_SIZE, height: CELL_SIZE))
            let from: UIImageView = UIImageView.init(frame: self.convert(fromRect, from: map))
            from.contentMode = .scaleAspectFit
            from.image = UIImage.init(cgImage: UIImage.init(named: "tileGrass_roadNorth")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.start))
            
            addSubview(from)
            
            let toRect: CGRect = CGRect.init(origin: self.determinePlayerCoordinate(coordinate: i.end), size: CGSize.init(width: CELL_SIZE, height: CELL_SIZE))
            let to: UIImageView = UIImageView.init(frame: self.convert(toRect, from: map))
            to.image = UIImage.init(cgImage: UIImage.init(named: "tileGrass_roadNorth")!.cgImage!, scale: 1.0, orientation: self.determinePlayerDirection(coordinate: i.end))
            to.contentMode = .scaleAspectFit
            
            addSubview(to)
            
            sendSubview(toBack: from)
            sendSubview(toBack: to)
            
        }
        
    }
    
    func determinePlayerDirection(coordinate: Coordinate) -> UIImageOrientation {
        if coordinate.x == 0 {
            return .left //east
        } else if coordinate.y == 0 {
            return .up //south
        } else if coordinate.x == Int(BOARD_WIDTH) {
            return .right //west
        } else if coordinate.y == Int(BOARD_HEIGHT) {
            return .down //north
        }
        
        return .up
    }
    
    func determinePlayerCoordinate(coordinate: Coordinate) -> CGPoint {
        return CGPoint.init(x: CELL_SIZE * CGFloat(coordinate.x) - (CELL_SIZE / 2), y: CELL_SIZE * CGFloat(coordinate.y) - (CELL_SIZE / 2))
        if coordinate.x == 0 {
            return CGPoint.init(x: -CELL_SIZE * 1.5, y: CGFloat(coordinate.y) * CELL_SIZE - (CELL_SIZE / 2))
        } else if coordinate.y == 0 {
            return CGPoint.init(x: CGFloat(coordinate.x) * CELL_SIZE - (CELL_SIZE / 2), y: -CELL_SIZE * 1.5)
        } else if coordinate.x == Int(BOARD_WIDTH) {
            return CGPoint.init(x: (BOARD_WIDTH) * CELL_SIZE + (CELL_SIZE / 2), y: CGFloat(coordinate.y) * CELL_SIZE - (CELL_SIZE / 2))
        } else if coordinate.y == Int(BOARD_HEIGHT) {
            return CGPoint.init(x: CGFloat(coordinate.x) * CELL_SIZE - (CELL_SIZE / 2), y: (BOARD_WIDTH) * CELL_SIZE + (CELL_SIZE / 2))
        }
        
        return CGPoint.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawPoint(coordinate: Coordinate, connections: [Connection], enabled: Bool, permanent: Bool) { map.drawPoint(coordinate: coordinate, connections: connections, enabled: enabled, permanent: permanent) }
    func drawConnection(from: Coordinate, to: Coordinate, color: UIColor) { map.drawConnection(from: from, to: to, color: color) }
    func drawPath(path: Path) { map.drawPath(path: path) }
    func traversePath(index: Int, path: Path, color: UIColor, completion: @escaping (() -> ())) { map.traversePath(index: index, path: path, color: color, completion: completion) }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let translatedPoint = map.convert(touches.first!.location(in: self), from: self)
        for i in map.roads {
            if i.frame.contains(translatedPoint) {
                
                self.gameManager.playerInteracted(road: i, interaction: self.interactionType)
                return
            }
        }
    }
}
