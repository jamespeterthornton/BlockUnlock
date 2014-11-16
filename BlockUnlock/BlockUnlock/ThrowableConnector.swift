//
//  ThrowableConnector.swift
//  blockunlocktests
//
//  Created by Sherif Nada on 11/15/14.
//  Copyright (c) 2014 Sherif Nada. All rights reserved.
//
//
/*
 TO-DO:
1)  Drag/Tap
1.5)
2)  Handle collision

*/

import Foundation
import SpriteKit

class ThrowableConnector: SKSpriteNode {

    let connectorType: String!
    
    required init(coder: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)

    }
    
    init(imageName: String, size: CGSize){
        var texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: nil, size: size)
        self.connectorType = imageName
    }
    
    
}
