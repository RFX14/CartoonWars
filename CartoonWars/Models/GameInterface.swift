//
//  GameInterface.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/25/26.
//

import SwiftUI

@Observable
// How players interact with game
class GameInterface {
    var gold: Int = 500
    var mana: Int = 0
    
    // Hold ref to the tower to actually do things
    var tower: Tower = Tower()
    var gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    // Places a new unit on the ground, SwiftUI responsible for restricting cooldowns
    func place<T: Upgradable>(troop: Troop<T>) {
        tower.place(troop: troop)
    }
    
    func toggleArrows() {
        tower.enableArrow.toggle()
    }
}
