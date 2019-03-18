//
//  Created by Bronson Lane
//  Copyright © 2019 iOSLife. All rights reserved.
//

import SpriteKit

@objcMembers
class MainMenu: SKScene{
    
    let titleLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let subTitleLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
//    let music = SKAudioNode(fileNamed: "cool-vibes")
    
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
//        addChild(music)
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        addChild(background)
        
        titleLabel.text = "Don't die."
        titleLabel.fontSize = 75
        titleLabel.zPosition = 1
        titleLabel.position.y = (titleLabel.position.y + 25)
        addChild(titleLabel)
        
        subTitleLabel.text = "Tap to start"
        subTitleLabel.fontSize = 50
        subTitleLabel.zPosition = 1
        subTitleLabel.position.y = (subTitleLabel.position.y - 50)
        addChild(subTitleLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
    }
}

