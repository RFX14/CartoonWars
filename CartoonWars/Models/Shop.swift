//
//  Shop.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/26/26.
//

import Foundation

class Shop {
    /// Returns a new troop with upgraded stats
    func upgrade<T: Upgradable>(troop: Troop<T>) -> T? {
        let newTroop = troop.type.init(stats: nil, animations: nil)
        
        return newTroop
    }
}
