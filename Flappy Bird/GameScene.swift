//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Aaron Elijah on 22/07/2017.
//  Copyright © 2017 Aaron Elijah. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var upperPipe = SKSpriteNode()
    var lowerPipe = SKSpriteNode()
    
    var timer = Timer()
    
    enum ColliderType : UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver : Bool = false
    
    var scoreLabel = SKLabelNode()
    
    var score : Int = 0
    
    var gameOverLabel = SKLabelNode()
    
    func makePipes() {
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/100))
        
        let movementAmount = arc4random() % UInt32(self.frame.height/2)
        
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        let gapHeight = bird.size.height * 4
        
        let upperPipeTexture = SKTexture(imageNamed: "pipe1.png")
        
        upperPipe = SKSpriteNode(texture: upperPipeTexture)
        upperPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + upperPipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        upperPipe.zPosition = 1
        upperPipe.run(movePipes)
        
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipeTexture.size())
        upperPipe.physicsBody?.isDynamic = false
        
        upperPipe.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        upperPipe.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        upperPipe.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(upperPipe)
        
        let lowerPipeTexture = SKTexture(imageNamed: "pipe2.png")
        
        lowerPipe = SKSpriteNode(texture: lowerPipeTexture)
        lowerPipe.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - lowerPipeTexture.size().height/2 - gapHeight/2 + pipeOffset)
        lowerPipe.zPosition = 1
        lowerPipe.run(movePipes)
        
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipeTexture.size())
        lowerPipe.physicsBody?.isDynamic = false
        
        lowerPipe.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        lowerPipe.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        lowerPipe.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(lowerPipe)
        
        let gap = SKNode()
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperPipeTexture.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(movePipes)
        
        // the bird is able to pass through the gap but we are still able to detect a collosion
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
        
    }
    
    // whenever the bird comes into contact with something with the same contactTestBitMask, then we have contact
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
        
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
                score += 1
            
                scoreLabel.text = String(score)
            
            } else {
        
                // stop the game
                self.speed = 0
        
                gameOver = true
            
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again"
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameOverLabel.zPosition = 2
            
                self.addChild(gameOverLabel)
            
                timer.invalidate()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
    }
    
    
    func setupGame() {
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        // setting up the two textures the bird takes in flight from the 2 images of the bird
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // actions are generally some kind of action or movement
        // animation is an action that animates between the 2 textures (stored in an array) every 0.1 seconds
        // makeBirdFlap is an action that performs animation forever
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.zPosition = 1
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        
        bird.physicsBody?.isDynamic = false
        
        // make the bird node run with this action
        bird.run(makeBirdFlap)
        
        // set it so it only detects collosions from other objects, not the bird
        // second: what catergory is the physics body that we are looking to see if it has collided, it is the bird
        // collosion bit mask makes it clear if two objects are allowed to pass through each other - this doesn't matter in our game as any contact is failure
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
        
        // .addChild is how we add an object or node to view controller
        self.addChild(bird)
        
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0), duration: 7)
        let shiftBackgroundAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0), duration: 0)
        let makeBGMoveForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBackgroundAnimation]))
        
        var i : CGFloat = 0
        
        while i < 3 {
            
            background = SKSpriteNode(texture: backgroundTexture)
            background.position = CGPoint(x: (backgroundTexture.size().width * i), y: self.frame.midY)
            background.size.height = self.frame.height
            background.zPosition = 0
            
            background.run(makeBGMoveForever)
            
            self.addChild(background)
            
            i += 1
        }
        
        let ground = SKNode()
        
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        scoreLabel.zPosition = 2
        
        self.addChild(scoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false {
        
            bird.physicsBody?.isDynamic = true
        
            // velocity must come before impulse otherwise it then immediately loses it's velocity as soon as the impulse is imparted
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        
            // bird.physicsBody!.isDynamic = true
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 85))
            
        } else if gameOver == true {
            
            gameOver = false
            
            score = 0
            
            self.speed = 1
            
            self.removeAllChildren()
            
            setupGame()
            
        }

        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
