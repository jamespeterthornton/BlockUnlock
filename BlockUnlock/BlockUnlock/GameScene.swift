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
let controlsHeight : CGFloat = 150
let targetHeight : CGFloat = 75
var gameOver : Bool = true
var score : Int = 0



class GameScene: SKScene {
    
    let MOVEDIFF = 6.0 // num of pixels that determines drag v drop
    let SPRITESIZE =  CGSizeMake(45, 42)
    var tappedSprite: SKSpriteNode!
    var gameOverSprite : GameOverSprite!
    var beginGameSprite : BeginGameSprite!
    var chosenValue : NSString!
    var lastMoveBegin: CGPoint!
    var lastMoveEnd: CGPoint!
    let scoreLabel : SKLabelNode = SKLabelNode()
    let evalLabel : SKLabelNode = SKLabelNode()
    
    
    override func didMoveToView(view: SKView) {
        //if (!gameOver) {
        /*      var myPath = CGPathCreateMutable()
        CGPathMoveToPoint(myPath, nil, CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame))
        CGPathAddLineToPoint(myPath, nil, CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame))
        var shape = SKShapeNode(path:myPath)
        shape.lineWidth = 1.0
        shape.fillColor = UIColor.blackColor()
        self.addChild(shape) */
        /* Setup your scene here */
        let andSprite = ThrowableConnector(imageName: "AND", size:SPRITESIZE)
        
        andSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
        andSprite.zPosition = 20
        self.addChild(andSprite)
        
        let orSprite = ThrowableConnector(imageName: "OR", size: SPRITESIZE)
        
        orSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + 2*self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
        orSprite.zPosition = 20
        self.addChild(orSprite)
        
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
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0, CGRectGetMaxY(self.frame) - 40.0);
        self.addChild(scoreLabel);
        
        evalLabel.text = "Nada"
        evalLabel.position = CGPointMake(CGRectGetMidX(self.frame) - 80.0, CGRectGetMaxY(self.frame) - 40.0);
        self.addChild(evalLabel);
        
        var playButton : Button = Button(defaultButtonImage: "playBut", activeButtonImage: "playBut_active", buttonAction: play)
        beginGameSprite = BeginGameSprite (spriteSize: CGSize(width: 400.0, height: 400.0), beginBut: playButton)
        
        beginGameSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        beginGameSprite.hidden = true
        self.addChild(beginGameSprite)
        

    //}
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
        if (type == "OR"){
            newSprite = ThrowableConnector(imageName: "OR", size: CGSizeMake(30, 28))
            newSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + 2 * self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
            newSprite.zPosition = 20
            self.addChild(newSprite)
        } else{
            newSprite = ThrowableConnector(imageName: "AND", size: CGSizeMake(30, 28))
            newSprite.position = CGPoint(x:CGRectGetMinX(self.frame) + self.frame.width/3, y:CGRectGetMinY(self.frame) + controlsHeight/2)
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
    
    func unselectSprite(){
        self.tappedSprite = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches{
            self.lastMoveEnd = touch.locationInNode(self)
            
            
            if (GameScene.distance(self.lastMoveEnd!, p2: self.lastMoveBegin!) >= self.MOVEDIFF){
                let location = touch.locationInNode(self)
                
                if let touchedNode = nodeAtPoint(location) as? ThrowableConnector{
                    
                    self.tappedSprite = makeNewThrowable(touchedNode.connectorType)
                }
                    
                    
                else if (self.tappedSprite != nil){
                    let distance = GameScene.distance(self.lastMoveBegin, p2: self.lastMoveEnd)
                    
                    let xdiff = ((self.lastMoveEnd.x - self.lastMoveBegin.x) / CGFloat(distance)) * 300
                    let ydiff = ((self.lastMoveEnd.y - self.lastMoveBegin.y) / CGFloat(distance)) * 300
                    let diffVector = CGVectorMake(xdiff, ydiff)
                    
                    //                    if blocks.count < 1{
                    
                    
                    
                    if self.tappedSprite as? ThrowableConnector != nil{
                        let action = SKAction.moveBy(diffVector, duration: 0.5)
                        println("Throw it here 2")
                        self.tappedSprite.runAction(SKAction.repeatActionForever(action))
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "unselectSprite", userInfo: nil, repeats: false)
                    }
                    //                    } else{
                    //                        //extendedVector = (//extendtoY, Y of topmostBlock)
                    //                        let topMostBlockY = blocks[0].position.y
                    //                        let xExtension =  extendVectorToYValue(diffVector, yValue: Double(topMostBlockY))
                    //                        var extendedVector = CGPointMake(CGFloat(xExtension), topMostBlockY)
                    //
                    //                        let nearestX = findNearestX(xExtension)
                    //
                    //
                    //
                    //                        //                        action
                    //                        //                        self.tappedSprite.runAction(SKAction.repeatActionForever(action))
                    //                        //                        self.tappedSprite = nil
                    //                    }
                    
                    
                    
                }
                
            }
        }
    }
    
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
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
                    let xdiff = ((self.lastMoveEnd.x - self.lastMoveBegin.x) / CGFloat(distance)) * 300
                    let ydiff = ((self.lastMoveEnd.y - self.lastMoveBegin.y) / CGFloat(distance)) * 300
                    let diffVector = CGVectorMake(xdiff, ydiff)
                    //                    var extendedVector =
                    
                    
                    if self.tappedSprite as? ThrowableConnector != nil{
                        
                        
                        println("Throw it here")
                        
                        let action = SKAction.moveBy(diffVector, duration: 0.5)
                        
                        self.tappedSprite.runAction(SKAction.repeatActionForever(action))
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "unselectSprite", userInfo: nil, repeats: false)
                    }
                }
            }
        }
    }
    
    //returns the new X value for the vector
    func extendVectorToYValue (vector: CGVector, yValue:Double) -> Double{
        return (yValue / Double(vector.dy)) * Double(vector.dx)
    }
    
    //returns the actual endpoint of the throw
    func findNearestX (xToCheck: Double) -> Double{
        var nearestX = 0.0
        if (blocks.count > 0){
            let topMostBlock = blocks[0] as ComplexBlock
            var connectors:[SKSpriteNode] = []
            for var i = 1; i < topMostBlock.sprites.count ; i += 2{
                connectors.append(topMostBlock.sprites[i] as SKSpriteNode)
            }
            
            var nearestX = 50000.0
            for connector in connectors{
                if Double(abs(Double(connector.position.x) - xToCheck)) < Double(nearestX){
                    nearestX = Double(abs(Double(connector.position.x) - xToCheck))
                }
            }
        }
        
        return nearestX
    }
    
    //constructs the curved path for the throw
    func findNewPath(from: CGPoint, vectorExtension: CGVector, endPoint: CGPoint) -> CGPathRef {
        let myPath = UIBezierPath()
        myPath.moveToPoint(from)
        let vectorMidPoint = CGPointMake(from.x + ((vectorExtension.dx - from.x) / 2),
            from.y +  ((vectorExtension.dy - from.y) / 2))
        myPath.addQuadCurveToPoint(endPoint, controlPoint: vectorMidPoint)
        return myPath.CGPath
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
        
        let newTargetNode = SKSpriteNode(texture: nil, color: targetColor.colorWithAlphaComponent(0.7), size: CGSizeMake(self.frame.width, targetHeight))
        
        newTargetNode.anchorPoint = CGPointMake(0.5, 0.0)
        
        newTargetNode.position.x = CGRectGetMidX(self.frame);
        newTargetNode.position.y = CGRectGetMinY(self.frame) + controlsHeight
        
        self.addChild(newTargetNode);
        
        targetSprites.append(newTargetNode);
    }
    
    func generateBlock () {
        if (!gameOver) {
            println("Generate block: Target sprites count: \(targetSprites.count)")
        
            let difficulty : Double = Double(arc4random()) % 4.0 + 2.0;
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
        if(!gameOver) {
            beginGameSprite.removeFromParent()
            println(5)
            //beginGameSprite.removeFromParent()
            println(10)
            if (counter == 300){ counter = 0;}
            if (counter == 0){ generateBlock();}
            counter++;
            
            for sprite in blocks {
                sprite.position.y -= 2;
            }
            
            if targetSprites.count > 0 && blocks.count > 0 {
                // if CGRectGetMaxY(blocks[0].frame) == CGRectGetMaxY(targetSprites[0].frame) {
                if blocks[0].position.y < CGRectGetMidY(targetSprites[0].frame) {
                    gameOver = true;
                    
                    var button: Button = Button(defaultButtonImage: "restartbut1", activeButtonImage: "restartbut1_active", buttonAction: restart)
                    
                    gameOverSprite = GameOverSprite (spriteSize: CGSize(width: 400.0, height: 400.0), restartBut: button)
                    
                    gameOverSprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                    
                    gameOverSprite.zPosition = 1500
                    
                    self.addChild(gameOverSprite)
                    
                }
            }
        } else {
            println(1)
            //beginGameSprite.zPosition = 1500
            beginGameSprite.hidden = false
            println(3)
        }
    }
    
    func play () {
        gameOver = false
        println("\(self.parent)")
        beginGameSprite.removeFromParent()
       
    }
    
    func restart () {
        
        for var i : Int = 0; i < blocks.count; ++i {
            let thisBlock : ComplexBlock = blocks.removeAtIndex(0)
            thisBlock.removeFromParent()
        }
        for var i : Int = 0; i < targets.count; ++i {
            targets.removeAtIndex(0)
        }
        for var i : Int = 0; i < targetSprites.count; ++i {
            let thisSprite : SKSpriteNode = targetSprites.removeAtIndex(0)
            thisSprite.removeFromParent()
        }
        
        gameOverSprite.removeFromParent()
        
        gameOver = false;
        
    }
    
}
