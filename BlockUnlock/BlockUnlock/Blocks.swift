//
//  Block.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import Foundation
import SpriteKit

class ComplexBlock : SKSpriteNode {
    
    init(values: [NSObject]) {
        
        super.init(texture: nil, color: nil, size: CGSize(width: 100, height: 100));
        
        
        let sprite = SKSpriteNode(imageNamed: "RedBlock");
        
        sprite.xScale = 0.5
        sprite.yScale = 0.5
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        
        
        self.addChild(sprite);
        
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
}

class Connector: NSObject {
    
    let writeable: Bool;
    
    let value: String;
    
    init(thisWriteable: Bool, thisValue: String) {
        
        writeable = thisWriteable
        value = thisValue
        
    }
    
}