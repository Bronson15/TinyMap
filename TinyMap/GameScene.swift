//
//  GameScene.swift
//  TinyMap
//
//  Created by Bronson Lane
//  Copyright © 2019 iOSLife. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let cam = SKCameraNode()
    let flashlight = SKNode()
    
    let background = SKSpriteNode(imageNamed: "background")
    
    var pauseButton = SKSpriteNode()
    
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    var bulletCount = 0
    
    let velocityMultiplier: CGFloat = 0.05
    
    lazy var player: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "player")
        sprite.position = CGPoint.zero
        sprite.zPosition = 1
        sprite.name = "player"
        sprite.scaleTo(screenWidthPercentage: 0.05)
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.isDynamic = false
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.collisionBitMask = 2
        sprite.physicsBody?.contactTestBitMask = 2
        return sprite
    }()
    
    lazy var moveJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: ScreenSize.width * -0.5 + js.radius + 45, y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = 6
        return js
    }()
    
    lazy var rotateJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: -(ScreenSize.width * -0.5 + js.radius + 45), y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = 6
        return js
    }()
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = 5
        background.scaleTo(screenWidthPercentage: 1.2)
        cam.addChild(background)
        addChild(player)
        
        cam.zRotation = 0
        
        score = 0
        scoreLabel.position.y = ScreenSize.height * -0.5
        scoreLabel.zPosition = 6
        cam.addChild(scoreLabel)
        
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.setScale(0.5)
        pauseButton.position = CGPoint(x: -(ScreenSize.width * -0.5), y: -(ScreenSize.height * -0.5))
        pauseButton.zPosition = 6
        cam.addChild(pauseButton)
        
        addChild(enemyContainer)
        addChild(flashlight)
    }
    
    func setupMoveJoystick() {
        cam.addChild(moveJoystick)
        
        moveJoystick.trackingHandler = { [unowned self] data in
            self.player.position = CGPoint(x: self.player.position.x + (data.velocity.x * self.velocityMultiplier),
                                         y: self.player.position.y + (data.velocity.y * self.velocityMultiplier))
        }
    }
    
    func isEnemyVisible(playerPos: CGPoint, angle: CGFloat, distance: CGFloat) {
        flashlight.removeAllChildren()
        
        let rayStart = playerPos
        
        let angleInDegrees = fmodf(360.0 + Float(angle) * (180.0 / Float(Double.pi)), 360.0)
        let startAngle = angleInDegrees - 50
        let endAngle = angleInDegrees + 50
        let increment: Float = 0.5
        
        for i in stride(from: startAngle, to: endAngle, by: increment) {
            
            let rayEndTest = CGPoint(x: (player.position.x + (distance * -sin(angle) + CGFloat(i))), y: (player.position.y + (distance * cos(angle) + CGFloat(i))))
            
            let line = SKShapeNode()
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: rayStart)
            pathToDraw.addLine(to: rayEndTest)
            line.path = pathToDraw
            line.strokeColor = SKColor.init(white: 1, alpha: 0.9)
            line.lineWidth = 0.1
            flashlight.zPosition = 3
            flashlight.addChild(line)
            
            enemyContainer.children.forEach{ $0.isHidden = true}
            
            scene?.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEndTest) { (body, point, normal, stop) in
                if let sprite = body.node as? SKSpriteNode, body.categoryBitMask == 2 {
                    sprite.isHidden = false
                }
            }
        }

        
    }
    
    var bulletTime = 0.0
    
    func addBulletOnRotate() {
        let bullet = SKSpriteNode(imageNamed: "player")
        bullet.position = self.player.position
        bullet.zPosition = 2
        bullet.name = "bullet"
        bullet.scaleTo(screenWidthPercentage: 0.01)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.categoryBitMask = 0
        bullet.physicsBody?.contactTestBitMask = 1 | 2
        bullet.physicsBody?.collisionBitMask = 0
        
        if self.bulletCount < 20 {
            if bulletTime == 0.0 {
                self.addChild(bullet)
                self.bulletCount += 1
                self.bulletTime += 1.0
            } else if bulletTime <= 10.0 {
                self.bulletTime += 1.0
            } else {
                self.bulletTime = 0
            }
        }
        
        let wait = SKAction.wait(forDuration: 2)
        let block = SKAction.run {
            bullet.removeFromParent()
            self.bulletCount -= 1
        }
        let removeBullet = SKAction.sequence([wait, block])
        run(SKAction.repeatForever(removeBullet))
        
        var dx = CGFloat(-sin(self.player.zRotation))
        var dy = CGFloat(cos(self.player.zRotation))
        
        let magnitude = sqrt(dx * dx + dy * dy)
        
        dx /= magnitude
        dy /= magnitude
        
        let vec = CGVector(dx: 2 * dx, dy: 2 * dy)
        bullet.physicsBody?.applyImpulse(vec)
    }
    
    func setupRotateJoystick() {
        cam.addChild(rotateJoystick)
        
        rotateJoystick.trackingHandler = { [unowned self] data in
            self.player.zRotation = data.angular
            //self.addBulletOnRotate()
        }
    }
    
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        isUserInteractionEnabled = true
        setupNodes()
        setupMoveJoystick()
        setupRotateJoystick()
        
        self.camera = cam
        
        addChild(cam)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let block = SKAction.run {
            self.createEnemy()
        }
        let spawnEnemy = SKAction.sequence([wait, block])
        
        run(SKAction.repeatForever(spawnEnemy))
        
        physicsWorld.contactDelegate = self
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player)
        cam.constraints = [ constraint ]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        for touch in touches
        {
            let location = touch.location(in: self)
            
            if scene?.isPaused != true{
                if pauseButton.contains(location) {
                    scene?.isPaused = true
                }
            } else {
                scene?.isPaused = false
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        for node in enemyContainer.children {
            run(SKAction.run {
                self.followPlayer(enemy: node as! SKSpriteNode)
            })
            
        }
        self.isEnemyVisible(playerPos: self.player.position, angle: self.player.zRotation, distance: 250)
    }
    
    func followPlayer(enemy: SKSpriteNode ) {
        
        let location = player.position
        
        //Aim
        let dx = location.x - enemy.position.x
        let dy = location.y - enemy.position.y
        let angle = atan2(dy, dx)
        
        enemy.zRotation = angle
        
        //Seek
        let vx = cos(angle) * 2
        let vy = sin(angle) * 2
        
        enemy.position.x += vx
        enemy.position.y += vy
    
    }
    
    var enemyContainer = SKSpriteNode()
    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "player")
        
        let angle = (CGFloat(arc4random_uniform(360)) * CGFloat.pi) / 180.0
        let radius = (size.width >= size.height ? (size.width + sprite.size.width) : (size.height + sprite.size.height)) / 2
        sprite.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
        sprite.name = "enemy"
        sprite.zPosition = 1
        sprite.scaleTo(screenWidthPercentage: 0.04)
        
        enemyContainer.addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 2
        sprite.physicsBody?.collisionBitMask = 0
        sprite.isHidden = true
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let node = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if (node.name == "bullet" && nodeB.name == "player") || (nodeB.name == "bullet" && node.name == "player") {
            return
        }
//        if node.name == "enemy" {
//            enemyHit(node)
//            if nodeB.name == "player" {
//                playerHit(nodeB)
//            } else if nodeB.name == "bullet" {
//                removeBullet(nodeB)
//            }
//        } else if node.name == "player" && nodeB.name == "enemy" {
//            playerHit(node)
//        } else if node.name == "bullet" {
//            removeBullet(node)
//            if nodeB.name == "enemy" {
//                enemyHit(nodeB)
//            }
//        }
    }
    
    func enemyHit(_ node: SKNode) {
        node.removeFromParent()
        bulletCount -= 1
        score += 1
    }
    
    func removeBullet(_ node: SKNode) {
        node.removeFromParent()
        bulletCount -= 1
    }
    
    func playerHit(_ node: SKNode) {
        node.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver-2")
        gameOver.zPosition = 10
        cam.addChild(gameOver)
        
        isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let scene = GameScene(fileNamed: "MainMenu") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}

