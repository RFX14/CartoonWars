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
            150
        case (.compact, .compact):
            50
        case (_, _):
            100
        }
    }

    var body: some View {
        // ZStack layers views on top of each other (bottom-to-top)
        ZStack {
            SpriteView(scene: game, preferredFramesPerSecond: 120, debugOptions: [.showsFPS, .showsPhysics])
                .ignoresSafeArea() // Pushes the game world behind the notch/home bar
            
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
                
                Spacer()
                
                HStack {
                    Slider(value: $game.tower.angle, in: 0...1)
                        .frame(maxWidth: 200)
                        .rotationEffect(.degrees(-90))
                        .padding(.leading, -50)
                    
                    Spacer()
                    
                    VStack {
                        GameButton(
                            text: "Soldier",
                            color: .red,
                            action: {
                            game.createTroop()
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
                            game.tower.enableArrow.toggle()
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
