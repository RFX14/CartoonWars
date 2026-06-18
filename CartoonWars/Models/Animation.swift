//
//  Animation.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/17/26.
//

import SpriteKit

enum AnimationState {
    case idle, walk, attack, block, death
}

struct Animations {
    let walk: InlineArray<8, SKTexture>
    let attack: InlineArray<6, SKTexture>
}
