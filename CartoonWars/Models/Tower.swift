//
//  Tower.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/18/26.
//

import SpriteKit

class Tower: SKSpriteNode {
    var frames: [SKTexture]!
    
    init(size: CGSize, isEnemy: Bool = false) {
        super.init(texture: nil, color: isEnemy ? .white : .cyan, size: size)
        
        self.frames = getAnimation(frameCount: 11, name: "tower")
        colorBlendFactor = 1
        
        let animation = SKAction.animate(with: frames, timePerFrame: 0.1)
        run(SKAction.repeatForever(animation))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getAnimation(frameCount: Int, name: String, flip: Bool = false) -> [SKTexture] {
        let sheetTexture = SKTexture(imageNamed: name)
        var frames: [SKTexture] = []
        let frameWidth: CGFloat = 1.0 / CGFloat(frameCount)

        for i in 0..<frameCount {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: 1.0)
            frames.append(SKTexture(rect: rect, in: sheetTexture))
        }
        
        return frames
    }
}
