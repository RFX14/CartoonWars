//
//  Tower.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/18/26.
//

internal import SpriteKit
import SwiftUI

class Tower: SKSpriteNode {
    var frames: [SKTexture]!
    var angle: Double
    var enableArrow: Bool
    let attackDmg: [Float16]
    
    init(isEnemy: Bool = false) {
        self.angle = 0
        self.attackDmg = [1, 3]
        self.enableArrow = false
        
        super.init(texture: nil, color: isEnemy ? .white : .cyan, size: .init(width: 140, height: 140))
        self.anchorPoint = .init(x: 0.5, y: 0) // Anchor is now the bottom of the sprite
        self.position = .init(x: isEnemy ? 3000 : 0, y: 0)
        self.zPosition = 1
        self.setScale(3)
        
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
    
    func shootArrow() {
        let arrow = Arrow(angle: .degrees(60 * angle))
        addChild(arrow)
        
        let speed: CGFloat = 500.0 + 500 * angle
        let dx = speed * cos(arrow.zRotation)
        let dy = speed * sin(arrow.zRotation)

        arrow.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
    
    func place<T: Upgradable>(troop: Troop<T>) {
        switch troop {
        case .soldier:
            parent?.addChild(Soldier())
        case .orc:
            parent?.addChild(Orc())
        }
    }
}

class Arrow: SKSpriteNode {
    let attackDmg: [Float16]
    
    init(angle: Angle) {
        attackDmg = [5]
        super.init(
            texture: .init(imageNamed: "arrow"),
            color: .white,
            size: .init(width: 64, height: 64)
        )
        
        self.position = .init(x: .zero, y: 70)
        self.zRotation = angle.radians
        
        setupPhysics()
    }
    
    private func setupPhysics() {
        // Create the physics body matching the sprite's size
        self.physicsBody = SKPhysicsBody(rectangleOf: .init(width: 10, height: 5))
        self.physicsBody?.categoryBitMask =  PhysicsCategory.Arrow.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy.rawValue | PhysicsCategory.Player.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.mass = 0.5

        // Allow it to be pushed by forces
        self.physicsBody?.isDynamic = true

        // Turn off gravity so it doesn't fall down
        self.physicsBody?.affectedByGravity = true

        // Prevent the sprite from spinning wildly when hit
        self.physicsBody?.allowsRotation = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
