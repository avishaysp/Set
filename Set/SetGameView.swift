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
            Text("Score: \(game.score)")
                .foregroundColor(.blue)
                .font(.headline)
                .padding(.top)
            gameBody.padding([.leading, .bottom, .trailing])
            Spacer()
            if !allDealt {
                deckBody
                    .transition(.asymmetric(insertion: .opacity, removal:  .opacity.animation(.easeInOut.delay(Constents.totalDealDuration))))
            }
            controlsBody.padding(.bottom)
        }
    }
    
    @State private var dealtCardsIndecies = Set<Int>()
    
    private func deal(_ card: CardSetGame.Card) {
        dealtCardsIndecies.insert(card.id)
    }
    
    private func undeal(_ card: CardSetGame.Card) {
        dealtCardsIndecies.remove(card.id)
    }
    
    private func isDealt(_ card: CardSetGame.Card) -> Bool {
        dealtCardsIndecies.contains(card.id)
    }
    
    private func zIndex(of card: CardSetGame.Card) -> Double {
        -Double(game.cardsToDisplay.firstIndex(where: { $0.id == card.id } ) ?? 0 )
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cardsToDisplay, aspectRatio: 1.42) {
            card in
            if isDealt(card) {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .foregroundColor(game.highlightColor(of: card))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        if game.nextChooseChangesLayout() {
                            withAnimation(.spring()) {
                                game.choose(card)
                            }
                        } else {
                            game.choose(card)
                        }
                    }
                    .transition(.scale.combined(with: .opacity.combined(with: .move(edge: .bottom))))
            } else { Color.clear }
        }
    }
    
    private func coinFlip() -> Bool {
        let results = [true, false]
        return results.randomElement()!
    }
    
    var deckBody: some View {
        @State var touched = false
        return VStack {
            ZStack {
                ForEach(game.cardsToDisplay.filter { !isDealt($0) }) { card in
                    ZStack {
                        CardView(card: card)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .foregroundColor(game.highlightColor(of: card))
                        .rotationEffect(coinFlip() ? Angle(degrees: 0) : (coinFlip() ? Angle(degrees: 2) : Angle(degrees: -2)))
                    }
                    .transition(.scale)
                    .zIndex(zIndex(of: card))
                }
            }
            .frame(width: Constents.undealtWidth, height: Constents.undealtHeight)
        }
        .onTapGesture {
            touched = true
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
    
    var controlsBody: some View {
        HStack {
            Spacer()
            restartButton
            Spacer()
            drowMoreButton
            Spacer()
            hintButton
            Spacer()
        }
    }
    
    var restartButton: some View {
        VStack {
            Image(systemName: "arrow.counterclockwise.circle")
                .font(.largeTitle)
            Text("Restart")
        }
        .foregroundColor(.blue)
        .onTapGesture {
            withAnimation {
                dealtCardsIndecies = []
                allDealt = false
                withAnimation(.linear(duration: 0.1).delay(0.2)) {
                    game.restart()
                }
            }
        }
    }
    
    var drowMoreButton: some View {
        ZStack {
            if allDealt && game.canDrawMore() {
                VStack {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                    Text("Drow")
                }
                .foregroundColor(.blue)
                .onTapGesture {
                    withAnimation {
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
    
    var hintButton: some View {
        ZStack {
            if allDealt && game.canHint() {
                VStack {
                    Image(systemName: "lightbulb")
                        .font(.largeTitle)
                    Text("Hint")
                }
                .foregroundColor(.blue)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        if !game.isHinting {
                            game.hint()
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
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack {
                let shape = RoundedRectangle(cornerRadius: width * Constents.corner)
                shape.fill().foregroundColor(.white)
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
        static let undealtWidth: CGFloat = 270
        static let undealtHeight: CGFloat = undealtWidth * aspectRatio
        static let maxWidth: CGFloat = 240
        static let maxHeight: CGFloat = maxWidth * aspectRatio
        static let corner: CGFloat = 0.12
        static let strokeWidth: CGFloat = 0.03
        static let fontSize: CGFloat = maxWidth * 0.1
        static let fontScale: CGFloat = 0.2
        static let padding: CGFloat = 0.06
    }
}





























struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let game = CardSetGame()
            SetGameView(game: game)
            .preferredColorScheme(.light)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPad (9th generation)"/*@END_MENU_TOKEN@*/)
            .edgesIgnoringSafeArea(.top)
            SetGameView(game: game)
            .preferredColorScheme(.dark)
            .previewDevice(/*@START_MENU_TOKEN@*/"iPad Air (5th generation)"/*@END_MENU_TOKEN@*/)
            .edgesIgnoringSafeArea(.top)

        }
    }
}
