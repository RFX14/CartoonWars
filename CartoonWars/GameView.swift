//
//  GameView.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/18/26.
//


import SwiftUI
internal import SpriteKit

struct GameView: View {
    @Environment(\.horizontalSizeClass) var horiSize
    @Environment(\.verticalSizeClass) var vertSize

    @State private var interface: GameInterface
    @State private var enemyInterface: GameInterface
    
    private let game: GameScene
    private let cpu: ComputerPlayer?
    
    init() {
        let gameState = GameState()
        self._interface = State(
            wrappedValue: GameInterface(gameState: gameState)
        )
        self._enemyInterface = State(
            wrappedValue: GameInterface(
                gameState: gameState,
                isEnemy: true
            )
        )
        self.cpu = ComputerPlayer(interface: self._enemyInterface.wrappedValue)
        
        self.game = GameScene(
            size: .init(
                width: 960,
                height: 540
            ),
            playerTower: _interface.wrappedValue.tower,
            enemyTower: self._enemyInterface.wrappedValue.tower,
            gameState: gameState, cpu: self.cpu
        )
    }
    
    var uiHeight: CGFloat {
        return switch (horiSize, vertSize) {
        case (.regular, .regular):
            150
        case (.regular, .compact):
            50
        case (.compact, .regular):
            150
        case (.compact, .compact):
            50
        case (_, _):
            100
        }
    }
    var gold: Int16 {
        interface.gold
    }
    var mana: Int16 {
        interface.mana.value
    }
    var maxMana: Int16 {
        interface.mana.max
    }

    var body: some View {
        // ZStack layers views on top of each other (bottom-to-top)
        ZStack {
            SpriteView(
                scene: game,
                preferredFramesPerSecond: 120,
                debugOptions: [.showsFPS, .showsPhysics]
            ).ignoresSafeArea() // Pushes the game world behind the notch/home bar
            
            VStack {
                HStack {
                    Text("Mana: \(mana)/\(maxMana)")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding()
                    Text("CPU Mana: \(enemyInterface.mana.value)/\(maxMana)")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("Gold: \(gold)")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Spacer() // Pushes the next item to the right edge
                    
                    Button(game.isPaused ? "Play" : "Pause") {
                        game.togglePause()
                    }.padding()
                }
                
                Spacer()
                
                HStack {
                    Slider(value: $interface.tower.angle, in: 0...1)
                        .frame(maxWidth: 200)
                        .rotationEffect(.degrees(-90))
                        .padding(.leading, -50)
                    
                    Spacer()
                    
                    VStack {
                        GameButton(
                            text: "Soldier",
                            color: .red,
                            action: {
                                let _ = interface.place(troop: Troop.soldier)
                        })
                    }.frame(width: uiHeight, height: uiHeight)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    GameButton(
                        text: "Arrow",
                        color: .blue,
                        action: {
                            interface.toggleArrows()
                    }).frame(width: uiHeight, height: uiHeight)
                }
            }
        }
    }
}

struct GameButton: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(color)
                Text(text)
                    .foregroundStyle(.white)
                    .bold()
            }
        })
    }
}
