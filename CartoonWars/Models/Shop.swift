//
//  Shop.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/26/26.
//

import Foundation

class Shop {
    /// Returns a new troop with upgraded stats
    func upgrade(troop: Troop) -> some Upgradable {
        let upgraded = switch troop {
        case .soldier:
            Soldier(stats: nil, animations: nil)
        case .orc:
            Orc(stats: nil, animations: nil)
        case .werewolf:
            Werewolf()
        case .knight:
            Knight()
        }
        
        return upgraded
    }
}
