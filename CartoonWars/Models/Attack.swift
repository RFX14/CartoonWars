//
//  Weapon.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/15/26.
//

internal import SpriteKit

struct Attack {
    let reciever: BaseTroop
    var dmgs: [Float16]
    let frequency: TimeInterval
    var prevHit: TimeInterval = 0
}

struct AttackPair {
    var nodeA: Attack
    var nodeB: Attack
    var isActive: Bool
}
