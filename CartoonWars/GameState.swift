//
//  GameState.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/26/26.
//

import Foundation
internal import SpriteKit

// General keep track of everything
// - Frontline
// - Who is winning/losing
// - Global timer?
class GameState {
    private var attacks: [AttackPair] = []
    private var prevFrontLine: Double? = nil
    var frontLineIsStuck: Bool = false
    
    private var lastCleanUp: TimeInterval = .zero
    private var lastFrontLineCheck: TimeInterval = .zero
    
    init() {
        attacks.reserveCapacity(500)
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
    
    // Performs attack
    private func attack(_ attack: inout Attack, currentTime: TimeInterval) {
        if attack.reciever.state != .attack {
            attack.reciever.attack()
        }
        
        
        if currentTime - attack.prevHit >= attack.frequency {
            let dmg = attack.dmgs.randomElement()!
            attack.reciever.takeDamage(dmg: dmg)
            attack.prevHit = currentTime
        }
    }
    
    func cleanUp(for currentTime: TimeInterval) {
        guard currentTime - lastCleanUp > 10 else { return }
        
        if Double(attacks.count) > Double(attacks.capacity) * 0.9 {
            attacks.removeAll(where: { !$0.isActive })
            lastCleanUp = currentTime
        }
    }
    
    func computeFrontLine(for currentTime: TimeInterval) {
        guard currentTime - lastFrontLineCheck > 2 else { return }
        
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
        guard frontLine > margin || frontLine < (3000 - margin) else { return }
        
        // Check if frontline has moved from previous frontline
        let distanceBetweenFrontLine = sqrt(pow(frontLine - prevFrontLine, 2))
        if distanceBetweenFrontLine <= margin {
            frontLineIsStuck = false
        } else {
            print("STUCK!!")
            frontLineIsStuck = true
        }
    }
}
