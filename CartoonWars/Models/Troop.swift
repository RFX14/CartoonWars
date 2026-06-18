//
//  Untitled.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import SpriteKit

class Troop: SKSpriteNode {
    var dmgs: [Float]
    var health: Float
    var isEnemy: Bool
    private var walkFrames: [SKTexture]!
    private var attackFrames: [SKTexture]!
    
    init(size: CGSize, color: UIColor = .white, mass: CGFloat = 5, isEnemy: Bool = false) {
        self.isEnemy = isEnemy
        self.dmgs = isEnemy ? [0, 3, 4] : [0, 2, 3.5]
        self.health = isEnemy ? 20 : 10
        
        super.init(texture: nil, color: color, size: size)
        
        colorBlendFactor = 1
        
        let walkName = isEnemy ? "Orc-Walk" : "Soldier-Walk"
        walkFrames = getAnimation(frameCount: 8, name: walkName)
        
        let attackName = isEnemy ? "Orc-Attack02" : "Soldier-Attack01"
        attackFrames = getAnimation(frameCount: 6, name: attackName)
        
        self.setScale(3)
        if isEnemy {
            self.xScale = -3
        }
        
        // Create the physics body matching the sprite's size
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask =  isEnemy ? PhysicsCategory.Enemy.rawValue : PhysicsCategory.Player.rawValue
        self.physicsBody?.contactTestBitMask = isEnemy ? PhysicsCategory.Player.rawValue : PhysicsCategory.Enemy.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue

        // Allow it to be pushed by forces
        self.physicsBody?.isDynamic = true

        // Turn off gravity so it doesn't fall down
        self.physicsBody?.affectedByGravity = false

        // Prevent the sprite from spinning wildly when hit
        self.physicsBody?.allowsRotation = false
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
    
    func walk(duration: CGFloat) {
        let direction = isEnemy ? -1 : 1
        let walkAnimation = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
        run(SKAction.repeatForever(walkAnimation))
        let walk = SKAction.move(by: .init(dx: 5000 * direction, dy: 0), duration: duration)
        run(walk, withKey: "movement")
    }
    
    // When someone else starts attacking
    func attack() {
        removeAction(forKey: "movement")
        let attackAnimation = SKAction.animate(with: attackFrames, timePerFrame: 0.1)
        run(SKAction.repeatForever(attackAnimation))
    }
    
    // Returns if troop is still active
    func takeDamage(dmg: Float) {
        health -= dmg
        if health <= 0 {
            print("Player should be removed, knockback")
            // knockback
            let direction = isEnemy ? 1 : -1
            let knockback = SKAction.move(
                by: .init(
                    dx: 300 * direction,
                    dy: 200
                ),
                duration: isEnemy ? 0.5 : 0.2
            )
            
            run(knockback) {
                self.removeFromParent()
            }
        }
    }
}
 
