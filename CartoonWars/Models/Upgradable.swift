//
//  Upgradable.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/25/26.
//

import Foundation

protocol Upgradable {
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
enum Troop<T: Upgradable> {
    case soldier, orc
    
    var type: T.Type {
        return T.self
    }
}

struct TroopUpgrade {
    let stats: Stats
    let animations: Animations
    let description: String?
}

class Shop {
    /// Returns a new troop with upgraded stats
    func upgrade<T: Upgradable>(troop: Troop<T>) -> T? {
        let newTroop = troop.type.init(stats: nil, animations: nil)
        
        return newTroop
    }
}
