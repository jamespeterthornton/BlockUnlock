//
//  GameScene.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import SpriteKit

var blocks: [SKSpriteNode] = [];

var counter: Int = 0;

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hellooo, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMinX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        println("WIDTH IS: \(self.frame.width.description)")
        
    }

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        NSLog("Touch!");
        
    }
    
    
    func generateBlock () {
        
        NSLog("Game scene width %@", self.frame.width);
        
        
        var complexBlock : ComplexBlock
        let easyOrHarder : NSNumber = Double(arc4random()) % 3;
        
        if (easyOrHarder == 0) {
            let trueNum: NSNumber = Double(arc4random()) % 2;
            let falseNum: NSNumber = Double(arc4random()) % 2;
            let connector = Connector(thisWriteable: true, thisValue: "OR", thisFixed: true, thisSeparator: false);
            let simpleArray: [NSObject] = [trueNum, connector, falseNum]
            complexBlock = ComplexBlock(newValues: simpleArray, makeWidth: self.frame.width);
            complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
        } else if easyOrHarder == 1 {
            
            let trueNum: NSNumber = Double(arc4random()) % 2;
            let falseNum: NSNumber = Double(arc4random()) % 2;
            let connector = Connector(thisWriteable: true, thisValue: "AND", thisFixed: true, thisSeparator: false);
            let bigConnector = Connector(thisWriteable: true, thisValue: "AND", thisFixed: true, thisSeparator: true);
            let simpleArray: [NSObject] = [trueNum, connector, falseNum, bigConnector, falseNum, connector, trueNum]
            complexBlock = ComplexBlock(newValues: simpleArray, makeWidth: self.frame.width);
            complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
            
        } else {
            
            let trueNum: NSNumber = Double(arc4random()) % 2;
            let falseNum: NSNumber = Double(arc4random()) % 2;
            let connector = Connector(thisWriteable: true, thisValue: "AND", thisFixed: true, thisSeparator: false);
            let bigConnector = Connector(thisWriteable: true, thisValue: "AND", thisFixed: true, thisSeparator: true);
            let simpleArray: [NSObject] = [trueNum, connector, falseNum, bigConnector, falseNum, connector, trueNum]
            complexBlock = ComplexBlock(newValues: simpleArray, makeWidth: self.frame.width);
            complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
            
        }
        
        self.addChild(complexBlock)
        blocks.append(complexBlock)

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if (counter == 100){ counter = 0;}
        if (counter == 0){ generateBlock();}
        counter++;
        
        for sprite in blocks {
            sprite.position.y -= 3;
        }
        
    }
}
