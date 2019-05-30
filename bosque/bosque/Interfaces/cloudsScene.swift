//
//  cloudsScene.swift
//  bosque
//
//  Created by João Melo on 22/05/19.
//  Copyright © 2019 João Melo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class cloudsScene: SKSpriteNode {
    
    init() {
        super.init(texture: nil, color: .clear, size: .zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func moveClouds(cloudName: String, width: CGFloat, height: CGFloat, speed: CGFloat) {
        let cloud = SKSpriteNode(imageNamed: cloudName)
        
        cloud.size = CGSize(width: width, height: height)
        
        let randomCloudYGenerator = GKRandomDistribution(lowestValue: 30, highestValue: Int(self.frame.height))
        let yPosition = CGFloat(randomCloudYGenerator.nextInt())
        
        let rightToLeft = arc4random() % 2 == 0
        
        let xPosition = rightToLeft ? self.frame.size.width + cloud.size.width / 2 : -cloud.size.width / 2
        
        cloud.position = CGPoint(x: xPosition, y: yPosition)
     
        self.addChild(cloud)
        
        var distanceToCover = self.frame.size.width + cloud.size.width
        
        // Definir o tempo para cada tipo de nuvem
        var timeVar = speed
        let time = TimeInterval(abs(distanceToCover / timeVar))
        
        let moveAction = SKAction.moveBy(x: distanceToCover, y: 0, duration: time)
        
        let removeAction = SKAction.run {
            cloud.removeAllActions()
            cloud.removeFromParent()
        }
        
        let allActions = SKAction.sequence([moveAction, removeAction])
        
        cloud.run(allActions)
    }
}
