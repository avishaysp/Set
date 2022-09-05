//
//  SetGameView.swift
//  Set
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: CardSetGame
    var body: some View {
        VStack {
            AspectVGrid(items: game.cardsToDisplay, aspectRatio: 1.42) {
                card in CardView(card: card)
                        .foregroundColor(card.highlightColor())
                        .onTapGesture { game.choose(card, playerNumber: 1) }
            }.padding()
            if game.canDrawMore() {
                Button {
                    game.drawThreeCards()
                } label: {
                    VStack {
                        Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                        Text("Drow").padding(.bottom)
                    }
                }
            } else {
                VStack {
                    Image(systemName: "rectangle.stack.badge.plus")
                    .font(.largeTitle)
                    Text("Drow")
                    .padding(.bottom)
                    .foregroundColor(.gray)
                }
            }
            
        }
    }
}

struct CardView: View {
    let card: CardSetGame.Card
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack {
                let shape = RoundedRectangle(cornerRadius: width * Consts.cornerConst)
                if card.displayIndex != nil {
                    shape.fill().foregroundColor(.white)
                    shape.stroke(lineWidth: width * Consts.strokeConst)
                    Text(String(CardSetGame.matchingValueOf(card)!))
                                    .foregroundColor(card.cardContent1)
                                    .font(.system(size: width * Consts.fontConst))
                } else {
                    shape.opacity(0)
                }
            }.padding(width * Consts.paddingConst)
        }
    }
    private struct Consts {
        static let cornerConst: CGFloat = 0.12
        static let strokeConst: CGFloat = 0.03
        static let fontConst: CGFloat = 0.25
        static let paddingConst: CGFloat = 0.06
        
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
