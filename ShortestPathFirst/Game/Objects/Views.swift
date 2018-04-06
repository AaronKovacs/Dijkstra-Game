//
//  Views.swift
//  ShortestPathFirst
//
//  Created by Aaron Kovacs on 4/5/18.
//  Copyright © 2018 Aaron Kovacs. All rights reserved.
//

import Foundation
import UIKit

class Truck: CALayer {}

class FromView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFit
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ToView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFit
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Road: UIView {
    
    var imageView: UIImageView = UIImageView.init(image: UIImage.init(named: "road.png"))
    
    var coordinate: Coordinate!
    var enabled: Bool = false
    var permanent: Bool = false
    
    var colorView: UIView = {
        var viw: UIView = UIView.init()
        return viw
    }()
    
    init(coordinate: Coordinate) {
        super.init(frame: CGRect.zero)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        clipsToBounds = false
        
        self.coordinate = coordinate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    func performTransition(color: UIColor) {
        self.colorView.backgroundColor = color
        self.colorView.frame = bounds
        self.colorView.alpha = 0.5
        self.colorView.layer.cornerRadius = 8
        addSubview(self.colorView)
        
        UIView.animate(withDuration: TRAVERSAL_TIME * 4, delay: 0.5, animations: {
            self.colorView.alpha = 0.0
        }) { (ok) in
            self.colorView.removeFromSuperview()
        }
    }
    
    func setTexture(connections: [Connection]) {
        var directions: [Direction] = [Direction]()
        for i in connections {
            if i.enabled && i.to.enabled {
                directions.append(i.direction)
            }
        }
        self.imageView.image = roadTexture(directions: directions)
    }
    
    private func roadTexture(directions: [Direction]) -> UIImage {
        
        if directions.count == 0 {
            return UIImage.init(named: "NotConnectedWE")!
        }
        
        if directions.count == 1 {
            
            if self.dirContains(directions: directions, contains: [.north]) {
                return UIImage.init(named: "DeadendN")!
            }
            
            if self.dirContains(directions: directions, contains: [.south]) {
                return UIImage.init(named: "deadEndS")!
            }
            
            if self.dirContains(directions: directions, contains: [.west]) {
                return UIImage.init(named: "deadEndW")!
            }
            
            if self.dirContains(directions: directions, contains: [.east]) {
                return UIImage.init(named: "DeadendE")!
            }
            
        }
        
        if directions.count == 2 {
            
            if self.dirContains(directions: directions, contains: [.north, .south]) {
                return UIImage.init(named: "tileGrass_roadNorth")!
            }
            
            if self.dirContains(directions: directions, contains: [.west, .east]) {
                return UIImage.init(named: "road")!
            }
            
            if self.dirContains(directions: directions, contains: [.east, .south]) {
                return UIImage.init(named: "tileGrass_roadCornerLR")!
            }
            
            if self.dirContains(directions: directions, contains: [.north, .east]) {
                return UIImage.init(named: "tileGrass_roadCornerUR")!
            }
            
            if self.dirContains(directions: directions, contains: [.north, .west]) {
                return UIImage.init(named: "tileGrass_roadCornerUL")!
            }
            
            if self.dirContains(directions: directions, contains: [.south, .west]) {
                return UIImage.init(named: "tileGrass_roadCornerLL")!
            }
            
        }
        
        if directions.count == 3 {
            if self.dirContains(directions: directions, contains: [.north, .west, .east]) {
                return UIImage.init(named: "tileGrass_roadSplitN")!
            }
            
            if self.dirContains(directions: directions, contains: [.south, .west, .east]) {
                return UIImage.init(named: "tileGrass_roadSplitS")!
            }
            
            if self.dirContains(directions: directions, contains: [.north, .south, .west]) {
                return UIImage.init(named: "tileGrass_roadSplitW")!
            }
            
            if self.dirContains(directions: directions, contains: [.north, .south, .east]) {
                return UIImage.init(named: "tileGrass_roadSplitE")!
            }
        }
        
        if directions.count == 4 {
            return UIImage.init(named: "road4")!
        }
        
        return UIImage.init(named: "road")!
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class HUD: UIView {
    
    var closeButton: LargeButton = {
        let btn: LargeButton = LargeButton.init()
        btn.setTitle("Close", for: .normal)
        return btn
    }()
    
    var newMap: LargeButton = {
        let btn: LargeButton = LargeButton.init()
        btn.setTitle("New Map", for: .normal)
        return btn
    }()
    
    init(frame: CGRect, target: Any, closeSelector: Selector, newMapSelector: Selector) {
        super.init(frame: frame)
        
        closeButton.addTarget(target, action: closeSelector, for: .touchUpInside)
        newMap.addTarget(target, action: newMapSelector, for: .touchUpInside)
        
        addSubview(closeButton)
        addSubview(newMap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.frame = CGRect.init(x: 16, y: 16, width: 80, height: 80)
        newMap.frame = CGRect.init(x: bounds.width - 16 - 80, y: 16, width: 80, height: 80)
        
    }
    
}

class StartView: UIView {
    
    var playerComputerButton: LargeButton = {
        let btn: LargeButton = LargeButton.init()
        btn.setTitle("Player v. Computer", for: .normal)
        return btn
    }()
    
    var computerComputerButton: LargeButton = {
        let btn: LargeButton = LargeButton.init()
        btn.setTitle("Computer v. Computer", for: .normal)
        return btn
    }()
    
    init(frame: CGRect, target: Any, playerComp: Selector, compComp: Selector) {
        super.init(frame: frame)
        
        playerComputerButton.addTarget(target, action: playerComp, for: .touchUpInside)
        computerComputerButton.addTarget(target, action: compComp, for: .touchUpInside)
        
        addSubview(playerComputerButton)
        addSubview(computerComputerButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerComputerButton.frame = CGRect.init(x: 16, y: bounds.height / 2, width: bounds.width - 32, height: 80)
        computerComputerButton.frame = CGRect.init(x: 16, y: playerComputerButton.frame.maxY + 16, width: bounds.width - 32, height: 80)
        
    }
    
}

class LargeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        backgroundColor = UIColor.gray
        setTitleColor(UIColor.white, for: .normal)
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 2.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        alpha = 1.0
    }
    
}
