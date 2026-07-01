//
//  ComputerPlayer.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/27/26.
//

import Foundation

class ComputerPlayer {
    private let interface: GameInterface
    private var saveMoneyTask: Task<Void, Never>?
    private let frequency: TimeInterval
    private var shouldSaveMana: Bool = false
    private var manaGoal: Int32 = 5
    private var root: Node?
    private var turnCount: Int
    
    // Timers
    private var lastTurnTime: TimeInterval = .zero
    
    init(interface: GameInterface) {
        self.interface = interface
        self.frequency = 0.5
        self.root = nil
        self.turnCount = 0
        setup()
    }
    
    /*
     ? Root Selector
     ├── -> Sequence (Analyze Board State - Runs Every Tick)
     │   ├── Action: Calculate Dynamic Mana Goal (Runs the code above)
     │   ├── Action: Update "shouldSaveMana" Flag (Based on current vs goal)
     │   └── Return: Failure (Forces the tree to drop down to the actual choices)
     ├── -> Sequence (Forced Save)
     │   ├── Condition: shouldSaveMana == true
     │   └── Action: Save Mana and End Turn
     │
     ├── -> Sequence (Has Troops State)
     │   ├── Condition: CPU Has Troops
     │   └── ? Selector (Purchase or Fallback)
     │       ├── Action: Buy Troop (Iterate Highest to Lowest Cost)
     │       └── Action: Save Mana and End Turn
     │
     └── -> Sequence (No Troops State)
         ├── Condition: CPU Has NO Troops
         └── ? Selector (Purchase or Fallback)
             ├── Action: Buy Troop (Iterate Medium to Lowest Cost)
             └── Action: Save Mana and End Turn
     */
    func setup() {
        let analyzeBoardState: () -> NodeResult = { [weak self] in
            guard let self else { return .success }
            
            // Save for medium if getting close to self
            if interface.gameState.isApproachingPlayer2 {
                manaGoal = 10
            }
            
            // If game just started, just aim for medium cheap
            if turnCount < 30 {
                manaGoal = 5
            }
            
            // If player1 has medium or higher, mana goal is most expensive item
            if turnCount > 30 && turnCount < 90 {
                manaGoal = 8
            }
            
            // If tower is low on health, goal is cheapest tower cost
            if interface.mana.value >= manaGoal {
                shouldSaveMana = false
            }
            
            return .failure
        }
        
        let saveMana: () -> NodeResult = { [weak self] in
            guard let self else { return .failure }
            
            self.shouldSaveMana = true
            return .success
        }
        
        let purchaseTop2Bottom: () -> NodeResult = { [weak self] in
            guard let self else { return .failure }
            
            for troop in Troop.allCases.sorted(by: { $0.cost > $1.cost }) where !troop.belongsToPlayer1 {
                if self.placeTroop(troop: troop) == .success {
                    return .success
                }
            }
            
            return .failure
        }
        
        let purchaseOrFallback = selector(nodes: [
            purchaseTop2Bottom,
            saveMana
        ])
        
        let hasTroops = sequence(nodes: [
            condition(self.interface.gameState.player2Troops != [:]),
            purchaseOrFallback
        ])

        let shouldSaveMana = sequence(nodes: [
            condition(self.shouldSaveMana)
        ])
        
        let root = selector(
            nodes: [
                analyzeBoardState,
                shouldSaveMana,
                hasTroops
            ]
        )
        
        self.root = root
    }
    
    func takeTurn(for currentTime: TimeInterval) {
        guard currentTime - lastTurnTime > frequency else { return }
        lastTurnTime = currentTime
        turnCount += 1
        
        let _ = root!()
    }
    
    func placeTroop(troop: Troop) -> NodeResult {
        if interface.place(troop: troop) {
            return .success
        }
        
        return .failure
    }
    
    private func saveMoney() {
        saveMoneyTask?.cancel()
        
        saveMoneyTask = Task { [weak self] in
            guard let self else { return }
            
            defer {
                saveMoneyTask = nil
            }
            
            do {
                try await Task.sleep(for: .seconds(5))
                shouldSaveMana = false
            } catch {
                shouldSaveMana = false
                print("Couldn't sleep")
            }
        }
    }
    
    // State machine?
    private func oldtakeTurn() {
        guard saveMoneyTask == nil else { return }
        
        if shouldSaveMana && saveMoneyTask == nil {
            saveMoney()
            return
        }
        
        // If stuck at own base then send out medium/powerful things
        // If stuck at own base and running low (<50%) on health send out cheap things
        // If closing in (50/75%) on own base then send medium things
        // If closing in on enemy (50/75%), send medium and a strong
        // If enemy low on health send medium and cheap
        
        if interface.gameState.frontLineIsStuck && interface.mana.value < 10 {
            // Should we save or keep trying? Lets gamble!
            shouldSaveMana = Bool.random()
            return
        }
        
        let _ = interface.place(troop: Troop.orc)
    }
}
