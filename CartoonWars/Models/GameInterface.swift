//
//  GameInterface.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/25/26.
//

import SwiftUI

@Observable
class GameInterface {
    var gold: Int16
    var mana: Mana
    var tower: Tower
    var gameState: GameState
    
    init(gameState: GameState, isEnemy: Bool = false, ) {
        self.gold = 500
        self.mana = Mana()
        self.tower = Tower(isEnemy: isEnemy)
        self.gameState = gameState
    }
    
    func place(troop: Troop) -> Bool {
        if mana.spend(on: troop) {
            if troop.belongsToPlayer1 {
                gameState.player1Troops[troop]! += 1
            } else {
                gameState.player2Troops[troop]! += 1
            }
            tower.place(troop: troop)
            return true
        }
        
        return false
    }
    
    func toggleArrows() {
        tower.enableArrow.toggle()
    }
}

@Observable
class Mana {
    private(set) var value: Int16
    private(set) var max: Int16
    
    private var task: Task<Void, Never>?
    private let frequency: Duration
    
    init() {
        self.value = 0
        self.max = 100
        self.frequency = .seconds(1)
        
        run()
    }
    
    deinit {
        stopTask()
    }
    
    func spend(on troop: Troop) -> Bool {
        let cost: Int16 = switch troop {
        case .soldier:
            1
        case .orc:
            2
        }
        
        if value >= cost {
            value -= cost
            return true
        }
        
        return false
    }
    
    private func run() {
        stopTask()
        
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                
                if value < max {
                    value += 1
                }
                
                do {
                    try await Task.sleep(for: frequency)
                } catch {
                    break
                }
            }
        }
    }
    
    private func stopTask() {
        task?.cancel()
        task = nil
    }
}
