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
//        let background = SKSpriteNode(imageNamed: "background-metal")
//        background.zPosition = -1
//        addChild(background)
        
        titleLabel.text = "Main Menu"
        titleLabel.fontSize = 75
        titleLabel.zPosition = 1
        titleLabel.position.y = CGFloat((ScreenSize.height / 2) + 50)
        addChild(titleLabel)
        
        subTitleLabel.text = "Don't die."
        subTitleLabel.fontSize = 50
        subTitleLabel.zPosition = 1
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

