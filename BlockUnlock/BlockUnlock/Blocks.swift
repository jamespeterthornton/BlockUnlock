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
    
    let separatorSize : CGFloat = CGFloat(40)
    let marginSize : CGFloat = CGFloat(30)
    
    let expressionSize : Double = 0
    let blockCount : CGFloat = 0
    let separatorCount : CGFloat = 0

    
    var values : [NSObject]
    
    /*
    * Initialize the block with an array of values.
    * The array will be used to construct the block. 
    * It can have NSNumbers (0 = False, 1 = True) or Connectors as elements
    */
    
    init(newValues: [NSObject], makeWidth: CGFloat) {
        
        values = newValues;
        
        for object in values {
            
            if object is NSNumber {
                expressionSize += 1;
                blockCount += 1
            } else if let connector = object as? Connector {
                if connector.separator {
                    expressionSize += 0.5;
                    separatorCount += 1;
                }
                
            } else {
                NSLog("Error: An element of the blocks value array was neither an NSNumber nor a Connector.");
            }
        }
        
        
        if expressionSize < 3 {
            
            super.init(texture: nil, color: UIColor.blueColor(), size: CGSize(width: 240, height: 100));

            placeBlocks(CGFloat(120));
            
        } else if expressionSize < 6 {
        
            //Hack-a-thon exception: I don't know why the mainScreen() is 
            //retrieving a size ~100px smaller than it should be... so
            // I'm just adding 100 px to it, lol.
            
            super.init(texture: nil, color: UIColor.blueColor(), size: CGSize(width: UIScreen.mainScreen().bounds.width + 100 - marginSize, height: 100));

            //Figure out how much space each block should take up
            
            let totalBlockWidth : CGFloat = self.frame.width - separatorCount * separatorSize
            
            let blockSize : CGFloat = totalBlockWidth / blockCount
            
            //Place each block and then each separator
            
            placeBlocks(blockSize)
            
        } else {
            super.init(texture: nil, color: nil, size: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 100));
            assert(false, "Must provide 2, 4, or 6 arguments in ComplexBlock constructor array");
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
 
    func placeBlocks (blockSize : CGFloat) {
        
        var xPlaceholder : CGFloat = 0;
        
        for object in values {
            
            if let number = object as? NSNumber  {
                
                var blockType: NSString = "RedBlock"
                if(number == 1){ blockType = "BlueBlock"}
                let sprite : SKSpriteNode = SKSpriteNode(imageNamed: blockType);
                let xScale : CGFloat = CGFloat(blockSize / sprite.frame.width);
                sprite.xScale = xScale;
                sprite.yScale = self.frame.height/sprite.frame.height
                sprite.anchorPoint = CGPointMake(0.0, 0.0);
                sprite.position = CGPointMake(xPlaceholder + CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
                xPlaceholder += sprite.frame.width;
                self.addChild(sprite);
                
            } else if let connector = object as? Connector {
                
                let sprite : SKSpriteNode = SKSpriteNode(imageNamed: connector.value)
                
                sprite.xScale = separatorSize/sprite.frame.size.width
                
                sprite.yScale = 0.09
                
                sprite.zPosition = 1000;
                
                if connector.separator {
                    
                    sprite.anchorPoint = CGPointMake(0.5, 0.5)
                    sprite.position = CGPointMake(xPlaceholder + CGRectGetMinX(self.frame) + separatorSize/2, CGRectGetMidY(self.frame))
                    xPlaceholder += separatorSize
                    
                } else {
                    sprite.anchorPoint = CGPointMake(0.5, 0.5)
                    sprite.position = CGPointMake(xPlaceholder + CGRectGetMinX(self.frame), CGRectGetMidY(self.frame))
                }
                self.addChild(sprite)
            }
        }
    }
}

class Connector: NSObject {
    
    let writeable: Bool
    
    let value: String
    
    let fixed: Bool
    
    let separator: Bool
    
    init(thisWriteable: Bool, thisValue: String, thisFixed: Bool, thisSeparator: Bool) {
        
        fixed = thisFixed
        writeable = thisWriteable
        value = thisValue
        separator = thisSeparator
        
    }
    
}