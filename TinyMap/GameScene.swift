//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameTimer: Timer?
    
    let screenTop = (-ScreenSize.height - 90)
    let screenBottom = (ScreenSize.height + 90)
    let screenLeft = (-ScreenSize.width)
    let screenRight = (ScreenSize.height)
    
    enum NodesZPosition: CGFloat {
        case background, player, joystick
    }
    
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    var bulletCount = 0
    
    let velocityMultiplier: CGFloat = 0.12
    
    lazy var player: SKSpriteNode = {
        var sprite = SKSpriteNode(imageNamed: "player")
        sprite.position = CGPoint.zero
        sprite.zPosition = 1
        sprite.name = "player"
        sprite.scaleTo(screenWidthPercentage: 0.05)
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        return sprite
    }()
    
    lazy var moveJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: ScreenSize.width * -0.5 + js.radius + 45, y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    lazy var rotateJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        js.position = CGPoint(x: -(ScreenSize.width * -0.5 + js.radius + 45), y: ScreenSize.height * -0.5 + js.radius + 45)
        js.zPosition = NodesZPosition.joystick.rawValue
        return js
    }()
    
    func setupNodes() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        addChild(background)
        addChild(player)
        
        
        score = 0
        scoreLabel.position.y = ScreenSize.height * -0.5
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    func setupMoveJoystick() {
        addChild(moveJoystick)
        
        moveJoystick.trackingHandler = { [unowned self] data in
            self.player.position = CGPoint(x: self.player.position.x + (data.velocity.x * self.velocityMultiplier),
                                         y: self.player.position.y + (data.velocity.y * self.velocityMultiplier))
        }
    }
    
    var bulletTime = 0.0
    
    func addBulletOnRotate() {
        let bullet = SKSpriteNode(imageNamed: "player")
        bullet.position = self.player.position
        bullet.name = "bullet"
        bullet.scaleTo(screenWidthPercentage: 0.01)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.categoryBitMask = 1
        
        if self.bulletCount < 20 {
            if bulletTime == 0.0 {
                self.addChild(bullet)
                self.bulletCount += 1
                self.bulletTime += 1.0
            } else if bulletTime <= 6.0 {
                self.bulletTime += 1.0
            } else {
                self.bulletTime = 0
            }
        }
        
        var dx = CGFloat(-sin(self.player.zRotation))
        var dy = CGFloat(cos(self.player.zRotation))
        let magnitude = sqrt(dx * dx + dy * dy)
        
        dx /= magnitude
        dy /= magnitude
        
        let vec = CGVector(dx: 2 * dx, dy: 2 * dy)
        bullet.physicsBody?.applyImpulse(vec)
    }
    
    func setupRotateJoystick() {
        addChild(rotateJoystick)
        
        rotateJoystick.trackingHandler = { [unowned self] data in
            self.player.zRotation = data.angular
            
            self.addBulletOnRotate()
        }
        
    }
    
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        isUserInteractionEnabled = true
        setupNodes()
        setupMoveJoystick()
        setupRotateJoystick()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        physicsWorld.contactDelegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        
        if player.position.x < -ScreenSize.height - 75 {
            player.position.x = -ScreenSize.height - 75
        } else if player.position.x > ScreenSize.height + 40 {
            player.position.x = ScreenSize.height + 40
        }
        
        if player.position.y < -160 {
            player.position.y = -160
        } else if player.position.y > 210 {
            player.position.y = 210
        }
        
        for bullet in self.children {
            if bullet.position.x < screenTop {
                bullet.removeFromParent()
                bulletCount -= 1
            } else if bullet.position.x > screenBottom {
                bullet.removeFromParent()
                bulletCount -= 1
            } else if bullet.position.y < screenLeft {
                bullet.removeFromParent()
                bulletCount -= 1
            } else if bullet.position.y > screenRight {
                bullet.removeFromParent()
                bulletCount -= 1
            }
        }
        
        for node in self.children {
            let location = player.position
            var enemy = SKNode()
            
            if node.name == "enemy" {
                enemy = node
            }
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
    }
    
    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "player")
        let intTop = Int(screenTop + 250)
        let intBottom = Int(screenBottom - 250)
        let intLeft = Int(screenLeft)
        let intRight = Int(screenRight)
        
        sprite.position = CGPoint(x: -(Int.random(in: (intLeft...intRight))), y: -(Int.random(in: (intTop...intBottom))))
        sprite.name = "enemy"
        sprite.zPosition = 1
        sprite.scaleTo(screenWidthPercentage: 0.04)
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let node = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if (node.name == "bullet" && nodeB.name == "player") || (nodeB.name == "bullet" && node.name == "player") {
            print("im in here")
            return
        }
        if node.name == "enemy" {
            enemyHit(node)
            if nodeB.name == "player" {
                playerHit(nodeB)
            }
        }
    }
    
    func enemyHit(_ node: SKNode) {
        node.removeFromParent()
        bulletCount -= 1
        score += 1
    }
    
    func playerHit(_ node: SKNode) {
        node.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver-2")
        gameOver.zPosition = 10
        addChild(gameOver)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isUserInteractionEnabled = false
            if let scene = GameScene(fileNamed: "MainMenu") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}

