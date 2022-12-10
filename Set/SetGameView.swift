//
//  SetGameView.swift
//  Set
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: CardSetGame
    @Namespace private var dealingNamespace
    
    @State private var allDealt: Bool = false
    
    var body: some View {
        VStack {
            controlsBody2
            ZStack(alignment: .bottomTrailing) {
                if !game.over() {
                    gameBody
                    Spacer()
                }
                if !allDealt {
                    deckBody
                } else {
                    Spacer()
                }
            }
            controlsBody1
        }
    }
    
    @State private var dealtCardsIds = Set<Int>()
    
    private func deal(_ card: CardSetGame.Card) {
        dealtCardsIds.insert(card.id)
    }
    
    private func undeal(_ card: CardSetGame.Card) {
        dealtCardsIds.remove(card.id)
    }
    
    private func isDealt(_ card: CardSetGame.Card) -> Bool {
        dealtCardsIds.contains(card.id)
    }
    
    private func zIndex(of card: CardSetGame.Card) -> Double {
        -Double(game.cardsToDisplay.firstIndex(where: { $0.id == card.id } ) ?? 0 )
    }

    @State private var showingGameFinishedAlert = false
        
    var gameBody: some View {
        AspectVGrid(items: game.cardsToDisplay, aspectRatio: 1.42) {
            card in
            if isDealt(card) {
                CardView(card: card, shadow: game.someoneIsPlaying)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .foregroundColor(game.highlightColor(of: card))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        if game.someoneIsPlaying {
                            game.choose(card)
                            if game.over() {
                                showingGameFinishedAlert = true
                            }
                        }
                    }
            } else { Color.clear }
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    
    private func coinFlip() -> Bool {
        let results = [true, false]
        return results.randomElement()!
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cardsToDisplay.filter { !isDealt($0) }) { card in
                ZStack {
                    CardView(card: card)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .foregroundColor(.gray)
                        .rotationEffect(coinFlip() ? Angle(degrees: 0) : (coinFlip() ? Angle(degrees: 2) : Angle(degrees: -2)))
                }
                .transition(.scale)
                .zIndex(zIndex(of: card))
            }
        }
        .frame(width: Constents.undealtWidth, height: Constents.undealtHeight)
        .onTapGesture {
            for i in 0..<game.cards.count {
                withAnimation(.easeInOut.delay(Double(i) * (Constents.totalDealDuration / Double(game.cardsToDisplay.count))))
                {
                    deal(game.cards[i])
                }
            }
            withAnimation(.easeInOut.delay(Constents.totalDealDuration)) {
                allDealt = true
            }
        }
    }
    
    var controlsBody1: some View {
        VStack {
            Text("Score: \(game.player1Score)").foregroundColor(.blue)
            HStack {
                Spacer()
                setButton1
                Spacer()
                restartButton
                Spacer()
                drowMoreButton
                Spacer()
                hintButton(player: 1, game: game, allDealt: allDealt)
                Spacer()
            }.padding(.bottom)
        }
        .alert("You Finished The Game", isPresented: $showingGameFinishedAlert) {
            Button("Play again", role: .cancel) {
                withAnimation {
                    dealtCardsIds = []
                    allDealt = false
                    withAnimation(.linear(duration: 0.1).delay(0.2)) {
                        game.restart()
                    }
                }
            }
        }
    }
    
    
    var controlsBody2: some View {
        VStack {
            Text("Score: \(game.player2Score)").foregroundColor(.blue)
            HStack {
                Spacer()
                setButton2
                Spacer()
                restartButton
                Spacer()
                drowMoreButton
                Spacer()
                hintButton(player: 2, game: game, allDealt: allDealt)
                Spacer()
            }.padding(.bottom)
        }.rotationEffect(.degrees(180))
    }
    
    var setButton1: some View {
        Group {
            if allDealt && game.playerPlaying != 2 {
                VStack {
                    Image(systemName: "figure.wave.circle")
                        .font(.largeTitle)
                    Text("Set!")
                }
                .foregroundColor(.blue)
                .onTapGesture {
                    game.resetChosenCards()
                    game.pressSet(byPlayer: 1)
                }
            } else {
                VStack {
                    Image(systemName: "figure.wave.circle")
                        .font(.largeTitle)
                    Text("Set!")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    var setButton2: some View {
        Group {
            if allDealt && game.playerPlaying != 1 {
                VStack {
                    Image(systemName: "figure.wave.circle")
                        .font(.largeTitle)
                    Text("Set!")
                }
                .foregroundColor(.blue)
                .onTapGesture {
                    game.resetChosenCards()
                    game.pressSet(byPlayer: 2)
                }
            } else {
                VStack {
                    Image(systemName: "figure.wave.circle")
                        .font(.largeTitle)
                    Text("Set!")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    @State private var showingRestartAlert = false
    
    var restartButton: some View {
        VStack {
            Image(systemName: "arrow.counterclockwise.circle")
                .font(.largeTitle)
            Text("Restart")
        }
        .foregroundColor(.blue)
        .onTapGesture {
            showingRestartAlert = true
        }
        .alert("Are you sure you want to restart the game?", isPresented: $showingRestartAlert) {
            Button("Yes", role: .destructive) {
                withAnimation {
                    dealtCardsIds = []
                    allDealt = false
                    withAnimation(.linear(duration: 0.1).delay(0.2)) {
                        game.restart()
                    }
                }
            }
            Button("No", role: .cancel) { }
        }
    }
    
    var drowMoreButton: some View {
        Group {
            if allDealt && game.canDrawMore() {
                VStack {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                    Text("Drow")
                }
                .foregroundColor(.blue)
                .onTapGesture {
                    withAnimation {
                        game.resetChosenCards()
                        game.drawThreeCards()
                        deal(game.cardsToDisplay[game.cardsToDisplay.count-3])
                        deal(game.cardsToDisplay[game.cardsToDisplay.count-2])
                        deal(game.cardsToDisplay[game.cardsToDisplay.count-1])
                    }
                    
                }
            } else {
                VStack {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                    Text("Drow")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    struct hintButton: View {
        let player: Int
        var game: CardSetGame
        var allDealt: Bool
        var body: some View {
            Group {
                if allDealt && game.canSet() {
                    VStack {
                        Image(systemName: "lightbulb")
                            .font(.largeTitle)
                        Text("Hint")
                    }
                    .foregroundColor(.blue)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            if !game.isHinting {
                                game.resetChosenCards()
                                game.hint(by: player)
                            } else {
                                game.stopHinting()
                            }
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "lightbulb")
                            .font(.largeTitle)
                        Text("Hint")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    
    
    private struct Constents {
        static let cornerRadius: CGFloat = 10
        static let aspectRatio: CGFloat = 2/3
        static let undealtWidth: CGFloat = 260
        static let undealtHeight: CGFloat = undealtWidth * 2/3
        static let totalDealDuration = 1.5
        static let individualDealDuration = 0.3
        
    }
}

struct CardView: View {
    let card: CardSetGame.Card
    var shadow: Bool = false
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack {
                let shape = RoundedRectangle(cornerRadius: width * Constents.corner)
                shape.fill().foregroundColor(.white).shadow(radius: shadow ? Constents.shadow : 0)
                shape.stroke(lineWidth: width * Constents.strokeWidth)
                Text(String(CardSetGame.matchingValueOf(card)!))
                .foregroundColor(card.cardContent1)
                .animation(.easeInOut(duration: 0.4))
                .font(.system(size: Constents.fontSize))
                .scaleEffect(width * Constents.fontScale / Constents.fontSize)
            }
            .padding(width * Constents.padding)
        }
    }

    private struct Constents {
        static let aspectRatio: CGFloat = 2/3
        static let maxWidth: CGFloat = 240
        static let maxHeight: CGFloat = maxWidth * aspectRatio
        static let corner: CGFloat = 0.12
        static let strokeWidth: CGFloat = 0.02
        static let fontSize: CGFloat = maxWidth * 0.1
        static let fontScale: CGFloat = 0.2
        static let padding: CGFloat = 0.06
        static let shadow: CGFloat = maxWidth * 0.04
    }
}





























struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let game = CardSetGame()
            SetGameView(game: game)
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPad (9th generation)"/*@END_MENU_TOKEN@*/)
            SetGameView(game: game)
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPad Air (5th generation)"/*@END_MENU_TOKEN@*/)
        }
    }
}
