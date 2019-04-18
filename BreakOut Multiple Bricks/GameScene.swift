//
//  GameScene.swift
//  BreakOut Multiple Bricks
//
//  Created by zamin ahmed on 4/2/19.
//  Copyright © 2019 zamin ahmed. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var playLabel = SKLabelNode()
    var livesLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var playingGame = false
    var removedBricks = 0
    var score = 0
    var lives = 3
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeLoseZone()
        makeLabels()
        resetGame()
    }
    
    func resetGame() {
        ball.removeFromParent()
        makeBall()
        paddle.removeFromParent()
        makePaddle()
        makeBricks()
        updateLabels()
    }
    
    func kickball(){
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 4, dy: 4))
    }
    
    func makeLabels() {
        playLabel.fontSize = 36
        playLabel.text = "Tap to start"
        playLabel.fontName = "Arial"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "play"
        addChild(playLabel)
        
        livesLabel.fontSize = 18
        livesLabel.fontColor = UIColor.black
        livesLabel.fontName = "Arial"
        livesLabel.position = CGPoint(x: frame.minX + 50, y: frame.minY + 18)
        addChild(livesLabel)
        
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor.black
        scoreLabel.fontName = "Arial"
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 18)
        addChild(scoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if(playingGame){
                print("User isn't playing")
                paddle.position.x = location.x
            }
            else {
                print("Starting Game")
                for node in nodes(at: location) {
                    //This is the problem spot..for some reason the node.name is not set equal to play
                    if node.name == "play"{
                        
                        playingGame = true
                        node.alpha = 0
                        score = 0
                        lives = 3
                        updateLabels()
                        kickball()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if(playingGame) {
                paddle.position.x = location.x
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        for brick in bricks { // loop through all of bricks,
            
            if contact.bodyA.node == brick ||
                contact.bodyB.node == brick {
                score += 1
                updateLabels()
                if brick.color == UIColor.blue {
                    brick.color = UIColor.orange
                }
                else if brick.color == UIColor.orange{
                    brick.color = UIColor.green
                }
                else {
                    brick.removeFromParent()
                    removedBricks += 1
                    if removedBricks == bricks.count {
                        gameOver(winner: true)
                    }
                }
            }
        }
        
        if contact.bodyA.node?.name == "loseZone" ||
            contact.bodyB.node?.name == "loseZone" {
            lives -= 1
            if lives > 0 {
                score = 0
                resetGame()
                kickball()
            }
            else {
                gameOver(winner: false)
            }
        }
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball object to the view
    }
    
    func makePaddle() {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBricks() {
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll()
        removedBricks = 0
        //Figures out the spacing between bricks
        let count = Int(frame.width)/55
        let xOffset = (Int(frame.width)-(count * 55)) / 2 + Int(frame.minX) + 25
        let top = Int(frame.maxY)
        
        // makes three rows of bricks across the top
        
        for x in 0..<count { makeBrick(x: x * 55 + xOffset, y: top - 15, color: UIColor.blue)}
        
        for x in 0..<count { makeBrick(x: x * 55 + xOffset, y: top - 40, color: UIColor.orange)}
        
        for x in 0..<count { makeBrick(x: x * 55+xOffset, y: top - 65, color: UIColor.orange)
        }
    }
    
    func makeBrick(x:Int,y:Int,color:UIColor){
        let brick = SKSpriteNode(color:color,size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeLoseZone() {
        let  loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 18)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func gameOver(winner:Bool){
        playingGame = false
        playLabel.alpha = 1
        resetGame()
        if(winner){
            playLabel.text = "You win! Tap to play again"
        }
        else {
            playLabel.text = "You lose! Try again"
        }
    }
    
    func updateLabels() {
        scoreLabel.text = "Score:\(score) "
        livesLabel.text = "Lives: \(lives) "
    }
}





















