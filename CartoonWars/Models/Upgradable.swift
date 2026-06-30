//
//  Upgradable.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/25/26.
//

import Foundation

protocol Upgradable: Hashable {
    var type: Troop { get }
    init(stats: Stats?, animations: Animations?) // Use default animations if none provided
}

struct Stats {
    let speed: Double
    let attackFrequency: Double
    let cooldown: TimeInterval
    let attackDmg: [Float16]
    var health: Float16
}

// Generics for performance, but consider Shared Protocol if messy later on
enum Troop: CaseIterable {
    case soldier, orc

    var cost: Int16 {
        switch self {
        case .soldier:
            1
        case .orc:
            2
        }
    }
    
    var belongsToPlayer1: Bool {
        switch self {
        case .soldier:
            true
        case .orc:
            false
        }
    }
}

struct TroopUpgrade {
    let stats: Stats
    let animations: Animations
    let description: String?
}
