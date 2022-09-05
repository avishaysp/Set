//
//  SetApp.swift
//  Set
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import SwiftUI

@main
struct SetApp: App {
    private let game = CardSetGame()
    
    var body: some Scene {
        WindowGroup {
            SetGameView(game: game)
        }
    }
}
