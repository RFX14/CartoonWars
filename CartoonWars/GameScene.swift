//
//  GameScene.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

internal import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private let cam = SKCameraNode()
    private var prevTime: TimeInterval = .zero
    private var cleanUp: TimeInterval = .zero
    
    let tower: Tower
    let enemyTower: Tower
    let gameState: GameState
    let cpu: ComputerPlayer?
    
    init(size: CGSize, playerTower: Tower, enemyTower: Tower, gameState: GameState, cpu: ComputerPlayer?) {
        self.tower = playerTower
        self.gameState = gameState
        self.enemyTower = enemyTower
        self.cpu = cpu
        super.init(size: size)
        
        scene?.scaleMode = .aspectFill
    }
    
    func togglePause() {
        isPaused.toggle()
        physicsWorld.speed = isPaused ? .zero : 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.camera = cam
        addChild(cam)
        setupCameraConstraints()
                
        createSky()
        createClouds()
        createAllCollisionZones()
        addChild(tower)
        addChild(enemyTower)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func setupCameraConstraints() {
        guard let camera = self.camera else { return }

        let uiHeight: CGFloat = 45
        
        // 1. Your desired absolute map boundaries
        let mapLeftEdge: CGFloat = -250
        let mapRightEdge: CGFloat = 3250
        
        // 2. Calculate half of your scene's width
        let halfScreenWidth = self.size.width / 2
        
        // 3. Calculate the true limits for the camera's CENTER point
        let lowerX = mapLeftEdge + halfScreenWidth
        let upperX = mapRightEdge - halfScreenWidth
        
        // 4. Create the X range using those new center limits
        let xRange = SKRange(lowerLimit: lowerX, upperLimit: upperX)
        
        // 5. Keep your Y-axis locked to the floor (as discussed previously)
        let groundYPosition: CGFloat = -50
        let cameraYLock = groundYPosition + (self.size.height / 2) - uiHeight
        let yRange = SKRange(constantValue: cameraYLock)
        
        // 6. Apply both constraints
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        camera.constraints = [constraint]
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Create new enemy every X secs
        if currentTime - prevTime >= 0.25 {
            if tower.enableArrow {
                tower.shootArrow()
            }
            cpu?.takeTurn(for: currentTime)
            prevTime = currentTime
        }
        
        gameState.updateAttacks(for: currentTime)
        gameState.cleanUp(for: currentTime)
        gameState.cleanUpZones(for: currentTime)
        gameState.computeFrontLine(for: currentTime)
    }
}

// MARK: Touch Response
extension GameScene {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let camera = self.camera else { return }
        
        // Get the current and previous touch locations in the scene
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        // Calculate the difference between touches (the drag distance)
        let translationX = location.x - previousLocation.x
        
        // Update the camera's position (invert the translation to move camera in direction of drag)
        camera.position.x -= translationX
    }
}

// MARK: Helper Creators
extension GameScene {
    private func createAllCollisionZones() {
        for zone in MapZone.allCases {
            createCollisionZone(zone: zone)
        }
    }
    
    private func createCollisionZone(zone: MapZone) {
        let width = zone.range.upperBound - zone.range.lowerBound
        let height: CGFloat = 300
        let rect = CGRect(x: zone.range.lowerBound, y: 0, width: width, height: height)
        let zoneNode = SKShapeNode(rect: rect)
        
        zoneNode.zPosition = 0
        zoneNode.fillColor = .red
        zoneNode.blendMode  = .add
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        zoneNode.physicsBody = SKPhysicsBody(rectangleOf: rect.size, center: center)
        zoneNode.physicsBody?.categoryBitMask =  getPhysicsZone(for: zone).rawValue
        zoneNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player.rawValue
        zoneNode.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        zoneNode.physicsBody?.isDynamic = false
        zoneNode.physicsBody?.affectedByGravity = false
        zoneNode.physicsBody?.allowsRotation = false
        
        addChild(zoneNode)
    }
    
    private func getPhysicsZone(for zone: MapZone) -> PhysicsCategory {
        return switch zone {
        case .zone0:
            .Zone0
        case .zone1:
            .Zone1
        case .zone2:
            .Zone2
        case .zone3:
            .Zone3
        case .zone4:
            .Zone4
        }
    }
    
    private func getMapZone(for physicsZone: PhysicsCategory) -> MapZone {
       return switch physicsZone {
        case .Zone0:
            .zone0
        case .Zone1:
            .zone1
        case .Zone2:
            .zone2
        case .Zone3:
            .zone3
        case .Zone4:
            .zone4
        default:
            fatalError("Not a zone!")
        }
    }
    
    private func createClouds() {
        for i in 1...6 {
            let cloud = SKSpriteNode(imageNamed: "cloud")
            cloud.zPosition = .greatestFiniteMagnitude
            cloud.anchorPoint = .init(x: 0.5, y: 0)
            let width = cloud.size.width * 0.5
            let xPos: CGFloat = (size.width / 2) + CGFloat(i) * width - size.width - 200
            let yPos: CGFloat = 400
            cloud.position = .init(x: xPos, y: yPos)
            cloud.setScale(0.2)
            addChild(cloud)
        }
    }
    
    private func createSky() {
        let sky = SKSpriteNode(imageNamed: "sky")
        sky.zPosition = .leastNormalMagnitude
        sky.setScale(0.3)
        cam.addChild(sky)
    }
}

// MARK: Physics Stuff
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        let collision = contactA | contactB
        let playerEnemyContact = PhysicsCategory.Player.rawValue | PhysicsCategory.Enemy.rawValue
        
        if collision == playerEnemyContact {
            // Stop the action immediately
            guard let nodeA = contact.bodyA.node as? BaseTroop else { return }
            guard let nodeB = contact.bodyB.node as? BaseTroop else { return }
            
            let attackA2B: Attack = Attack(
                reciever: nodeB,
                frequency: nodeA.isEnemy ? 1 : 0.4,
                dmgs: nodeA.stats.attackDmg,
            )
            
            let attackB2A: Attack = Attack(
                reciever: nodeA,
                frequency: nodeB.isEnemy ? 1 : 0.4,
                dmgs: nodeB.stats.attackDmg,
            )
            
            let pair: AttackPair = .init(
                nodeA: attackA2B,
                nodeB: attackB2A,
                isActive: true
            )
            
            gameState.append(attack: pair)
            
            // Attacking animation
            nodeA.attack()
            nodeB.attack()
        } else if contactA == PhysicsCategory.Arrow.rawValue {
            guard let nodeA = contact.bodyA.node as? Arrow else { return }
            guard let nodeB = contact.bodyB.node as? BaseTroop else { return }
            
            nodeB.takeDamage(dmg: nodeA.attackDmg.first!)
            
            nodeA.removeFromParent()
        } else if contactB == PhysicsCategory.Arrow.rawValue {
            guard let nodeB = contact.bodyB.node as? Arrow else { return }
            guard let nodeA = contact.bodyA.node as? BaseTroop else { return }
            
            nodeA.takeDamage(dmg: nodeB.attackDmg.first!)
            nodeB.removeFromParent()
        }
        
        checkZoneCollision(bodyA: contact.bodyA, bodyB: contact.bodyB)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        let collision = contactA | contactB
        let physicsZones: [PhysicsCategory] = [.Zone0, .Zone1, .Zone2, .Zone3, .Zone4]
        var i = 0
        for physicsZone in physicsZones {
            let expectedCollision = PhysicsCategory.Player.rawValue | physicsZone.rawValue
            
            if collision == expectedCollision {
                let zone: MapZone = getMapZone(for: physicsZone)
                gameState.player1Zones[zone] = nil
                return
            }
            i += 1
        }
    }
    
    private func checkZoneCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
        guard let nodeA = bodyA.node else { return }
        guard let nodeB = bodyB.node else { return }
        
        let contactA = bodyA.categoryBitMask
        let contactB = bodyB.categoryBitMask
        let collision = contactA | contactB
        
        let physicsZones: [PhysicsCategory] = [.Zone0, .Zone1, .Zone2, .Zone3, .Zone4]
        var i = 0
        for physicsZone in physicsZones {
            let expectedCollision = PhysicsCategory.Player.rawValue | physicsZone.rawValue
            
            if collision == expectedCollision {
                let zone: MapZone = getMapZone(for: physicsZone)
                if let node = getNewNode(for: zone, nodeA: nodeA, nodeB: nodeB) {
                    gameState.player1Zones[zone] = node
                    return
                }
            }
            i += 1
        }
    }
    
    private func getNewNode(for zone: MapZone, nodeA: SKNode, nodeB: SKNode) -> BaseTroop? {
        if let troop = gameState.player1Zones[zone] {
            if troop.state == .death {
                if let nodeA = nodeA as? BaseTroop {
                    return nodeA
                } else {
                    return nodeB as? BaseTroop
                }
            }
        } else {
            if let nodeA = nodeA as? BaseTroop {
                return nodeA
            } else if let nodeB = nodeB as? BaseTroop {
                return nodeB
            }
        }
        
        return nil
    }
}
