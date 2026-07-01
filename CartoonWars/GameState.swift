//
//  GameState.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/26/26.
//

import Foundation
internal import SpriteKit

enum MapZone: CaseIterable {
    case zone0, zone1, zone2, zone3, zone4
    
    var range: Range<CGFloat> {
        switch self {
        case .zone0:
            0..<300
        case .zone1:
            300..<1100
        case .zone2:
            1100..<1900
        case .zone3:
            1900..<2700
        case .zone4:
            2700..<3000
        }
    }
}

// General keep track of everything
// - Frontline
// - Who is winning/losing
// - Global timer?
class GameState {
    private var attacks: [AttackPair] = []
    var prevFrontLine: Double? = nil
    private var lastCleanUp: TimeInterval = .zero
    private var lastZoneCleanUp: TimeInterval = .zero
    private var lastFrontLineCheck: TimeInterval = .zero
    var player1Troops: [Troop: Int]
    var player2Troops: [Troop: Int]
    var isApproachingPlayer2: Bool
    var player1Zones: [MapZone: BaseTroop]
    var frontLineIsStuck: Bool = false
    
    init() {
        let allCases: [Troop] = Troop.allCases
        let troops1: [(Troop, Int)] = allCases.compactMap {
            if $0.belongsToPlayer1 {
                return ($0, 0)
            }
            
            return nil
        }
        
        let troops2: [(Troop, Int)] = allCases.compactMap {
            if $0.belongsToPlayer1 {
                return nil
            }
            
            return ($0, 0)
        }
                
        self.attacks.reserveCapacity(500)
        self.player1Troops = Dictionary(uniqueKeysWithValues: troops1)
        self.player2Troops = Dictionary(uniqueKeysWithValues: troops2)
        self.isApproachingPlayer2 = false
        self.player1Zones = [:]
    }
    
    func updateAttacks(for currentTime: TimeInterval) {
        for (idx, pair) in attacks.enumerated() where pair.isActive {
            // Perform Attacks
            attack(&attacks[idx].nodeA, currentTime: currentTime)
            attack(&attacks[idx].nodeB, currentTime: currentTime)
            
            // Ensure at least one of the nodes is alive to keep attacking
            let nodeA = attacks[idx].nodeA
            let nodeB = attacks[idx].nodeB
            if nodeA.reciever.stats.health <= 0 {
                attacks[idx].isActive = false
                nodeB.reciever.walk()
            } else if nodeB.reciever.stats.health <= 0 {
                attacks[idx].isActive = false
                nodeA.reciever.walk()
            }
        }
    }
    
    func append(attack: AttackPair) {
        attacks.append(attack)
    }
    
    func cleanUp(for currentTime: TimeInterval) {
        guard currentTime - lastCleanUp > 10 else { return }
        lastCleanUp = currentTime
        
        let count: Double = Double(attacks.count)
        let capacity: Double = Double(attacks.capacity)
        guard count > capacity * 0.9 else { return }
        
        attacks.removeAll(where: { !$0.isActive })
    }
    
    func cleanUpZones(for currentTime: TimeInterval) {
        guard currentTime - lastZoneCleanUp > 3 else { return }
        lastZoneCleanUp = currentTime
        
        for zone in MapZone.allCases {
            if let troop = player1Zones[zone] {
                if troop.state == .death {
                    player1Zones.removeValue(forKey: zone)
                }
            }
        }
    }
    
    func computeFrontLine(for currentTime: TimeInterval) {
        guard currentTime - lastFrontLineCheck > 2 else { return }
        lastFrontLineCheck = currentTime
        
        // Sort all points
        let points: [Double] = attacks.lazy.map {
            // Only use positionA because when attacking nodeB is in roughly the same position
            let positionA = $0.nodeA.reciever.position.x
            
            return positionA
        }.sorted(by: { $0 < $1 })
        
        guard let maxPoint: Double = points.last else { return }
        guard let minPoint: Double = points.first else { return }
        
        // Calculate distance to tower
        let player1Distance = minPoint
        let player2Distance = 3000 - maxPoint
        
        // New Front Line
        let frontLine = player1Distance < player2Distance ? minPoint : maxPoint
        defer {
            // Update prevFrontLine once done with everything
            prevFrontLine = frontLine
        }
        
        // Check if there is a prev front line
        let margin: Double = 110
        guard let prevFrontLine else { return }
        isApproachingPlayer2 = frontLine >= 3000 - (margin * 3)
        guard frontLine > margin || frontLine < (3000 - margin) else { return }
        
        // Check if frontline has moved from previous frontline
        let distanceBetweenFrontLine = sqrt(pow(frontLine - prevFrontLine, 2))
        if distanceBetweenFrontLine <= margin {
            frontLineIsStuck = false
        } else {
            frontLineIsStuck = true
        }
    }
}

// Private things
extension GameState {
    // Performs attack
    private func attack(_ attack: inout Attack, currentTime: TimeInterval) {
        if attack.reciever.state != .attack {
            attack.reciever.attack()
        }
        
        if currentTime - attack.prevHit >= attack.frequency {
            let dmg = attack.dmgs.randomElement()!
            attack.reciever.takeDamage(dmg: dmg)
            if attack.reciever.state == .death {
                let troopType = attack.reciever.type
                if troopType.belongsToPlayer1 {
                    player1Troops[troopType]! -= 1
                } else {
                    player2Troops[troopType]! -= 1
                }
            }
            attack.prevHit = currentTime
        }
    }
}
