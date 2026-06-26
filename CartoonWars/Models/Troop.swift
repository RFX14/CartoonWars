//
//  Untitled.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import SpriteKit

class BaseTroop: SKSpriteNode {
    /// Public Properties
    let isEnemy: Bool
    var stats: Stats
    var state: TroopState
    
    /// Private Properties
    private let animations: Animations
    
    init(stats: Stats, animations: Animations, isEnemy: Bool) {
        self.stats = stats
        self.animations = animations
        self.isEnemy = isEnemy
        self.state = .idle
        
        super.init(texture: nil, color: .white, size: .init(width: 64, height: 64))
        self.anchorPoint = .init(x: 0.5, y: 0.25) // Anchor is now the bottom of the sprite
        self.setScale(3)
        self.xScale = isEnemy ? -3 : 3
        self.position = isEnemy ? .init(x: 3000, y: .zero) : .zero
        self.zPosition = 2
        
        setupPhysics()
        walk() 
    }
    
    private func setupPhysics() {
        // Create the physics body matching the sprite's size
        self.physicsBody = SKPhysicsBody(
            rectangleOf: .init(width: 35, height: 35),
            center: .init(x: .zero, y: 50)
        )
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
    
    func walk() {
        guard stats.health > 0 else { return }
        removeAllActions()
        
        state = .walk
        let walkAnimation = SKAction.animate(with: animations.walk, timePerFrame: 0.1)
        run(SKAction.repeatForever(walkAnimation))
        
        let enemyTowerPosition: CGPoint = isEnemy ? .zero : .init(x: 3000, y: 0)
        let currentDistance: CGFloat = sqrt(pow(enemyTowerPosition.x - position.x, 2))
        
        let duration: TimeInterval = (currentDistance * stats.speed) / 3000
        let move = SKAction.move(
            to: enemyTowerPosition,
            duration: duration
        )
        
        run(move) {
            self.attack()
        }
    }
    
    func death() {
        physicsBody = nil // remove physics body to prevent dead ones from staying
        removeAllActions()
        state = .death
        
        // knockback
        let direction = isEnemy ? 1 : -1
        let knockback = SKAction.move(
            to: .init(
                x: Int(position.x) + (300 * direction),
                y: 0
            ),
            duration: isEnemy ? 0.5 : 0.4
        )
        
        let deathAnimation = SKAction.animate(with: animations.death, timePerFrame: 0.1)
        
        run(deathAnimation)
        run(knockback) {
            self.removeFromParent()
        }
    }
    
    func attack() {
        guard stats.health > 0 else { return }
        removeAllActions()
        
        state = .attack
        let attackAnimation = SKAction.animate(with: animations.attack, timePerFrame: 0.1)
        run(SKAction.repeatForever(attackAnimation))
    }
    
    func takeDamage(dmg: Float16) {
        stats.health -= dmg
        if stats.health <= 0 {
            death()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class Soldier: BaseTroop, Upgradable {
    init(stats: Stats? = nil, animations: Animations? = nil) {
        let animations: Animations = if let animations {
            animations
        } else {
            .init(
                walk: (0...7).map { SKTexture(imageNamed: "soldier_walk\($0)") },
                attack: (0...5).map { SKTexture(imageNamed: "soldier_attack\($0)") },
                death: (0...3).map { SKTexture(imageNamed: "soldier_death\($0)") }
            )
        }
        
        let stats: Stats = if let stats {
            stats
        } else {
            .init(speed: 15, attackFrequency: 0.5, cooldown: 0.25, attackDmg: [0, 2, 3.5], health: 10)
        }
        
        super.init(stats: stats, animations: animations, isEnemy: false)
    }
        
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class Orc: BaseTroop, Upgradable {
    init(stats: Stats? = nil, animations: Animations? = nil) {
        let animations: Animations = if let animations {
            animations
        } else {
            .init(
                walk: (0...7).map { SKTexture(imageNamed: "orc_walk\($0)") },
                attack: (0...5).map { SKTexture(imageNamed: "orc_attack\($0)") },
                death: (0...3).map { SKTexture(imageNamed: "orc_death\($0)") }
            )
        }
        
        let stats: Stats = if let stats {
            stats
        } else {
            .init(speed: 18, attackFrequency: 0.75, cooldown: 0.25, attackDmg: [0, 2.5, 4], health: 11)
        }
        
        super.init(stats: stats, animations: animations, isEnemy: true)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
