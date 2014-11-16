//
//  GameScene.swift
//  BlockUnlock
//
//  Created by James Thornton on 11/15/14.
//  Copyright (c) 2014 James Thornton. All rights reserved.
//

import SpriteKit



var blocks: [ComplexBlock] = []
var targets: [Bool] = []
var targetSprites : [SKSpriteNode] = []
var counter: Int = 0
let controlsHeight : CGFloat = 75
let targetHeight : CGFloat = 75
var gameOver : Bool = false
var score : Int = 0



class GameScene: SKScene {
    
    let MOVEDIFF = 6.0 // num of pixels that determines drag v drop
    let SPRITESIZE =  CGSizeMake(45, 42)
    var tappedSprite: SKSpriteNode!
    var gameOverSprite : GameOverSprite!
    var chosenValue : NSString!
    var lastMoveBegin: CGPoint!
    var lastMoveEnd: CGPoint!
    let scoreLabel : SKLabelNode = SKLabelNode()
    let evalLabel : SKLabelNode = SKLabelNode()
    
    let counterReset : Int = 150
    let fallingSpeed : CGFloat = CGFloat(3)
    

    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        let andSprite = ThrowableConnector(imageName: "AND", size:SPRITESIZE)
        
        andSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
        andSprite.zPosition = 20
        self.addChild(andSprite)
        
        let orSprite = ThrowableConnector(imageName: "OR", size: SPRITESIZE)
        
        orSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + 2*self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
        orSprite.zPosition = 20
        self.addChild(orSprite)
        
        let xorSprite = ThrowableConnector(imageName: "XOR", size: SPRITESIZE)
        
        xorSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/2, y:CGRectGetMinY(self.frame) + controlsHeight/2)
        xorSprite.zPosition = 20
        self.addChild(xorSprite)
        
        self.backgroundColor = UIColor.whiteColor()
        
        let backgroundSprite : SKSpriteNode = SKSpriteNode(imageNamed: "Background")
        
        backgroundSprite.xScale = UIScreen.mainScreen().bounds.width + 140 / backgroundSprite.frame.width
        backgroundSprite.yScale = 600.0/backgroundSprite.frame.height
        
        backgroundSprite.anchorPoint = CGPointMake(0.5, 0.0)
        
        backgroundSprite.position.x = CGRectGetMidX(self.frame)
        backgroundSprite.position.y = CGRectGetMinY(self.frame) + controlsHeight
        backgroundSprite.zPosition = -1
        self.addChild(backgroundSprite)

        scoreLabel.text = "\(score)"
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 60.0);
        scoreLabel.zPosition = 1500;
        self.addChild(scoreLabel);
        
    }
    
    //MARK: - Static code
    
    class func distance(p1: CGPoint, p2: CGPoint) -> Double{
        let xdiff = p1.x - p2.x
        let ydiff = p1.y - p2.y
        return sqrt( Double((xdiff * xdiff)) + Double((ydiff * ydiff)) )
    }
    
    //MARK: -instance methods
    
    func makeNewThrowable(type: String) -> ThrowableConnector{
        var newSprite:ThrowableConnector
        if (type == "AND"){
            newSprite = ThrowableConnector(imageName: "AND", size: SPRITESIZE)
            newSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
            newSprite.zPosition = 20
            self.addChild(newSprite)
        } else if (type == "OR") {
            newSprite = ThrowableConnector(imageName: "OR", size: SPRITESIZE)
            newSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + 2 * self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
            newSprite.zPosition = 20
            self.addChild(newSprite)
        } else {
            newSprite = ThrowableConnector(imageName: "XOR", size: SPRITESIZE)
            newSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/2, y:CGRectGetMinY(self.frame) + controlsHeight/2)
            newSprite.zPosition = 20
            self.addChild(newSprite)
        }
        
        return newSprite
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        println("Touch")
        
        for touch in touches{
            
            lastMoveBegin = touch.locationInNode(self)
            if let touchedNode = nodeAtPoint(lastMoveBegin) as? ThrowableConnector{
                
                println("I'm in it, I'm in it")
                
                tappedSprite = makeNewThrowable(touchedNode.connectorType)
                chosenValue = touchedNode.connectorType
                
            } else if let touchedNode = nodeAtPoint(lastMoveBegin) as? SKSpriteNode {
                
                if blocks.count >= 1{
                    if let index : Int = find(blocks[0].sprites, touchedNode) {
                        
                        if let updateConnector = blocks[0].values[index] as? Connector {
                            
                            if chosenValue != nil && updateConnector.setType(chosenValue) {
                                
                                blocks[0].sprites[index].texture = SKTexture(imageNamed: chosenValue)
                                
                                println("Evaluate")
                                
                                
                                if blocks[0].isSolved() {
                                    println("Success")
                                    evaluateTrue()
                                }
                                
                            }
                        }
                        println("Sicknasty shit dawg")
                    }
                }
                
            }
        }
        
    }
    
    func unselectSprite(){
        self.tappedSprite.removeFromParent()
//        self.tappedSprite = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        println("into moved:")
        
        for touch in touches{
            self.lastMoveEnd = touch.locationInNode(self)
            
            
            if (GameScene.distance(self.lastMoveEnd!, p2: self.lastMoveBegin!) >= self.MOVEDIFF){
                let location = touch.locationInNode(self)
                
                if let touchedNode = nodeAtPoint(location) as? ThrowableConnector{
                    
//                    self.tappedSprite = makeNewThrowable(touchedNode.connectorType)
                }
                    
                    
                else if (self.tappedSprite != nil){
                    let distance = GameScene.distance(self.lastMoveBegin, p2: self.lastMoveEnd)
                    
                    let xdiff = (self.lastMoveEnd.x - self.lastMoveBegin.x)
                    let ydiff = (self.lastMoveEnd.y - self.lastMoveBegin.y)
                    let diffVector = CGVectorMake(xdiff, ydiff)
                    

                    
                    
                    
                    if self.tappedSprite as? ThrowableConnector != nil{
                        if (blocks.count >= 1){
                            println("Throw it here 2")
                            
                            var topMostY = Double(blocks[0].position.y)
                            var extendedX = extendVectorToYValue(diffVector, yValue: topMostY - Double(self.lastMoveBegin.y))
                            
                            var endPoint = CGPointMake(CGFloat(findNearestX(extendedX + Double(self.lastMoveBegin.x))), CGFloat(topMostY))
                            if var touchedPoint:SKSpriteNode = nodeAtPoint(endPoint) as? SKSpriteNode{
                                let action = SKAction.moveTo(endPoint, duration: 0.2)
                                self.tappedSprite.runAction(action)
                                
                                if let index:Int = find(blocks[0].sprites, touchedPoint){
                                    if let updateConnector = blocks[0].values[index] as? Connector{
                                        if chosenValue != nil && updateConnector.setType(chosenValue){
                                            blocks[0].sprites[index].texture = SKTexture(imageNamed: chosenValue)
                                            
                                            if blocks[0].isSolved(){
                                                evaluateTrue()
                                            }
                                        }
                                    }
                                }
                                
                                NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "unselectSprite", userInfo: nil, repeats: false)
                            }
                            
                        }

                    }
                }
            }
        }
        
                println("out of moved:")
        
    }
    

    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
                println("into ended:")
        
        for touch in touches{
            self.lastMoveEnd = touch.locationInNode(self)
            
            //tap
            if (GameScene.distance(self.lastMoveEnd, p2: self.lastMoveBegin) < self.MOVEDIFF){
                
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                
                
                if (self.tappedSprite != nil){   //if we tap for a second time
                    
                    
                    if (touchedNode as? SKSpriteNode != nil){   //if we tap a node
                        if (self.tappedSprite == touchedNode){
                            self.tappedSprite = nil;
                        } else{
                            self.tappedSprite = touchedNode as? SKSpriteNode
                        }
                    } else{ // we tapped the gamescene
                        self.tappedSprite = nil
                    }
                } else{ // we tapped for a first time
                    if (touchedNode as? SKSpriteNode != nil){ // if we tapped a node
                        self.tappedSprite = touchedNode as? SKSpriteNode
                    }
                }
            } else { //drag
                
                
                let location = touch.locationInNode(self)
                let touchedNode = nodeAtPoint(location)
                if (touchedNode as? SKSpriteNode != nil && self.tappedSprite != nil){
                    
                    let distance = GameScene.distance(self.lastMoveBegin, p2: self.lastMoveEnd)
                    let xdiff = (self.lastMoveEnd.x - self.lastMoveBegin.x)
                    let ydiff = (self.lastMoveEnd.y - self.lastMoveBegin.y)
                    let diffVector = CGVectorMake(xdiff, ydiff)
                    
                    
                    if self.tappedSprite as? ThrowableConnector != nil{
                        if (blocks.count >= 1){
                            
                            
                            println("Throw it here")
                            var topMostY = Double(blocks[0].position.y)
                            var extendedX = extendVectorToYValue(diffVector, yValue: topMostY - Double(self.lastMoveBegin.y))
                            
                            var endPoint = CGPointMake(CGFloat(findNearestX(extendedX + Double(self.lastMoveBegin.x))), CGFloat(topMostY))
                                if var touchedPoint:SKSpriteNode = nodeAtPoint(endPoint) as? SKSpriteNode {
                                let action = SKAction.moveTo(endPoint, duration: 0.2)
                                self.tappedSprite.runAction(action)
                                
                                if let index:Int = find(blocks[0].sprites, touchedPoint){
                                    if let updateConnector = blocks[0].values[index] as? Connector{
                                        if chosenValue != nil && updateConnector.setType(chosenValue){
                                            blocks[0].sprites[index].texture = SKTexture(imageNamed: chosenValue)
                                            
                                            if blocks[0].isSolved(){
                                                evaluateTrue()
                                            }
                                        }
                                    }
                                }
                                
                                NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "unselectSprite", userInfo: nil, repeats: false)
                            }
                            }
                            
                    }
                }
            }
        }
        
                println("out of ended:")
        
    }
    
    //returns the new X value for the vector
    func extendVectorToYValue (vector: CGVector, yValue:Double) -> Double{
        return (yValue / Double(vector.dy)) * Double(vector.dx)
    }
    
    //returns the actual endpoint of the throw
    func findNearestX (xToCheck: Double) -> Double{
        var nearestX = 0.0
        var nearestXScore = 0.0
        if (blocks.count > 0){
            let topMostBlock = blocks[0] as ComplexBlock
            var connectors:[SKSpriteNode] = []
            
            for var i = 1; i < topMostBlock.sprites.count ; i += 2{
                connectors.append(topMostBlock.sprites[i] as SKSpriteNode)
            }
            
            nearestXScore = 50000.0
            for connector in connectors{
                if Double(abs(Double(connector.position.x + topMostBlock.position.x) - xToCheck)) < Double(nearestXScore){
                    nearestXScore = Double(abs(Double(connector.position.x + topMostBlock.position.x) - xToCheck))
                    nearestX = Double(connector.position.x + topMostBlock.position.x)
                }
            }
        }
        
        return nearestX
    }

    
    func evaluateTrue() {
    
        if(!gameOver) {
            
            if targetSprites.count > 0 {
                
                score += 1
                scoreLabel.text = "\(score)"
                
                println("\(targetSprites.count)");
                
                let block : ComplexBlock = blocks.removeAtIndex(0);
                let targetSprite : SKSpriteNode = targetSprites.removeAtIndex(0);
                
                let moveAction = SKAction.moveTo(CGPointMake(targetSprite.position.x, targetSprite.position.y), duration: 0.3);
                
                block.runAction(moveAction, completion: { () -> Void in
                    
                    block.hasExploded()
                    self.explode( block.position.x, y: block.position.y)
                    block.hidden = true
                    targetSprite.removeFromParent()
                    
                })
                
                
                if targets.count > 0 {
                
                    let target : Bool = targets.removeAtIndex(0);

                    addTarget(target)
                }
            }
        }
    }
    
    func addTarget(color : Bool) {
        
        println("Add target")
        
        let targetColor : UIColor = color ? UIColor.blueColor() : UIColor.redColor()
        
        let newTargetNode = SKSpriteNode(texture: nil, color: targetColor, size: CGSizeMake(self.frame.width, targetHeight))
        
        newTargetNode.alpha = 0.0;
        
        newTargetNode.anchorPoint = CGPointMake(0.5, 0.0)
        
        newTargetNode.position.x = CGRectGetMidX(self.frame);
        newTargetNode.position.y = CGRectGetMinY(self.frame) + controlsHeight
        
        self.addChild(newTargetNode);
        
        let fadeInAction : SKAction = SKAction.fadeAlphaTo(CGFloat(0.7), duration: 1.0)
        
        
        newTargetNode.runAction(fadeInAction)
        
        targetSprites.append(newTargetNode);
    }
    
    func generateBlock () {
        
        println("Generate block: Target sprites count: \(targetSprites.count)")
        
        var difficulty : Double = Double(arc4random()) % 4.0 + 2.0;
        
        if difficulty > 3.0 {
            
            difficulty = Double(arc4random()) % 4.0 + 2.0
            
            if difficulty > 4.0 {
                
                difficulty = Double(arc4random()) % 4.0 + 2.0
                
            }
            
        }
        
        let simpleArray : GenericBlock = GenericBlock(difficulty: Int(difficulty));
        let newTarget : Bool = simpleArray.goal;
        let complexBlock : ComplexBlock = ComplexBlock(thisBlock: simpleArray);
        
        complexBlock.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 300);
        self.addChild(complexBlock)
        blocks.append(complexBlock)
        
        if (targetSprites.count == 0) {
            addTarget(newTarget)
        } else {
            targets.append(newTarget);
        }
        
    }
    
    func explode(x: CGFloat, y: CGFloat) {
        var sparkEmmitterPath:NSString = NSBundle.mainBundle().pathForResource("redExplosion", ofType: "sks")!
        var sparkEmmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkEmmitterPath) as SKEmitterNode
        sparkEmmiter.position.x = x
        sparkEmmiter.position.y = y
        sparkEmmiter.name = "sparkEmmitter"
        sparkEmmiter.targetNode = self
        self.addChild(sparkEmmiter)
        
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "destroyParticle:", userInfo: sparkEmmiter, repeats: false)
        
        println("exploded")
    }
    
    func destroyParticle(timer: NSTimer) -> () {
        println(1)
        var userInfo = timer.userInfo as SKEmitterNode
        println("\(userInfo.parent)")
        userInfo.removeFromParent()
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
      //  if(!gameOver) {
            if (counter == counterReset){ counter = 0;}
        
            for sprite in blocks {
                sprite.position.y -= fallingSpeed;
            }
        if (!gameOver) {
            if (counter == 0){ generateBlock();}

            if targetSprites.count > 0 && blocks.count > 0 {
               // if CGRectGetMaxY(blocks[0].frame) == CGRectGetMaxY(targetSprites[0].frame) {
                  if blocks[0].position.y < CGRectGetMidY(targetSprites[0].frame) {
                    gameOver = true;
                    
                    var button: Button = Button(defaultButtonImage: "restartBut1", activeButtonImage: "restartBut1_active", buttonAction: restart)
                    
                    gameOverSprite = GameOverSprite (spriteSize: CGSize(width: 400.0, height: 400.0), restartBut: button, score: score)
                    
                    gameOverSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                    
                    gameOverSprite.zPosition = 1500
                    
                    self.addChild(gameOverSprite)
                    
                }
            }
            counter++;

        }
      //  }
    }
    
    func restart () {
        
        gameOver = true
        
        score = 0;
        
        scoreLabel.text = "0";
        
        while blocks.count > 0 {
            let thisBlock : ComplexBlock = blocks.removeAtIndex(0)
            thisBlock.removeFromParent()
        }
        while (targets.count > 0) {
            targets.removeAtIndex(0)
        }
        while (targetSprites.count > 0) {
            let thisSprite : SKSpriteNode = targetSprites.removeAtIndex(0)
            thisSprite.removeFromParent()
        }
        gameOverSprite.removeFromParent()
        gameOver = false;
        counter = 0;
    }
    
}
