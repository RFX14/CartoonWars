//
//  GameInterface.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/25/26.
//

import SwiftUI

class ComputerPlayer {
    let interface: GameInterface
    private var task: Task<Void, Never>?
    private let frequency: Duration
    
    init(gameState: GameState, interface: GameInterface) {
        self.interface = interface
        self.frequency = .milliseconds(500)
        run()
    }
    
    deinit {
        stopTask()
    }
    
    private func run() {
        stopTask()
        
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                
                takeTurn()
                
                do {
                    try await Task.sleep(for: frequency)
                } catch {
                    break
                }
            }
        }
    }
    
    private func takeTurn() {
        interface.place(troop: Troop<Orc>.orc)
    }
    
    private func stopTask() {
        task?.cancel()
        task = nil
    }
}

@Observable
class GameInterface {
    var gold: Int
    var mana: Int
    
    var tower: Tower
    let gameState: GameState
    
    init(gameState: GameState, isEnemy: Bool = false) {
        self.gameState = gameState
        self.gold = 500
        self.mana = 0
        self.tower = Tower(isEnemy: isEnemy)
    }
    
    // Places a new unit on the ground, SwiftUI responsible for restricting cooldowns
    func place<T: Upgradable>(troop: Troop<T>) {
        tower.place(troop: troop)
    }
    
    func toggleArrows() {
        tower.enableArrow.toggle()
    }
}
