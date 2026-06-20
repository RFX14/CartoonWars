//
//  GameView.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/18/26.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.horizontalSizeClass) var horiSize
    @Environment(\.verticalSizeClass) var vertSize

    @State var game: GameScene = GameScene(size: CGSize(width: 960, height: 540))
    
    var uiHeight: CGFloat {
        return switch (horiSize, vertSize) {
        case (.regular, .regular):
            150
        case (.regular, .compact):
            50
        case (.compact, .regular):
            100
        case (.compact, .compact):
            50
        case (_, _):
            100
        }
    }

    var body: some View {
        // ZStack layers views on top of each other (bottom-to-top)
        ZStack {
            // 2. The Base Layer: Your SpriteKit Game
            SpriteView(scene: game, preferredFramesPerSecond: 120, debugOptions: [.showsFPS])
                .ignoresSafeArea() // Pushes the game world behind the notch/home bar
            
            // 3. The Top Layer: Your SwiftUI HUD
            VStack {
                HStack {
                    Text("Gold: 500")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Spacer() // Pushes the next item to the right edge
                    
                    Button("Pause") {
                        print("Pause Button Tapped")
                    }
                    .padding()
                }
                
                Spacer() // Pushes the HUD up to the top of the screen
                
                // You could put a bottom row of tower selection buttons here
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.black)
                    Button(action: {
                        game.createTroop()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.red)
                            Text("Soldier")
                                .bold()
                        }
                    })
                }
                .padding(.top)
                .padding(.bottom, -15)
                .frame(width: uiHeight, height: uiHeight)
            }
        }
    }
}
