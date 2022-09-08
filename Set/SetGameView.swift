//
//  SetGameView.swift
//  Set
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var game: CardSetGame
    @State var isHinting = false
    var body: some View {
        VStack {
            AspectVGrid(items: game.cardsToDisplay, aspectRatio: 1.42) {
                card in CardView(card: card)
                    .foregroundColor(game.highlightColor(of: card))
                    .onTapGesture {
                        game.choose(card)
                        print(card.displayIndex!)
                    }
                    .transition(.scale.combined(with: .opacity.combined(with: .move(edge: .bottom))))
            }.padding()
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "arrow.counterclockwise.circle")
                    .font(.largeTitle)
                    Text("Restart").padding(.bottom)
                }
                .foregroundColor(.blue)
                .onTapGesture {withAnimation(.spring()) { game.restart() } }
                Spacer()
                if game.canDrawMore() {
                    VStack {
                        Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                        Text("Drow").padding(.bottom)
                    }
                    .foregroundColor(.blue)
                    .onTapGesture {withAnimation { game.drawThreeCards() } }
                } else {
                    VStack {
                        Image(systemName: "rectangle.stack.badge.plus")
                        .font(.largeTitle)
                        Text("Drow")
                        .padding(.bottom)
                        .foregroundColor(.gray)
                    }
                }
                Spacer()
                if game.canHint() {
                    VStack {
                        Image(systemName: "lightbulb")
                        .font(.largeTitle)
                        Text("Hint").padding(.bottom)
                    }
                    .foregroundColor(.blue)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            if !isHinting {
                                game.hint()
                                isHinting = true
                            } else {
                                game.stopHinting()
                                isHinting = false
                            }
                        }
                        
                    }
                } else {
                    VStack {
                        Image(systemName: "lightbulb")
                        .font(.largeTitle)
                        Text("Hint")
                        .padding(.bottom)
                        .foregroundColor(.gray)
                    }
                }
                Spacer()
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
                        .animation(.easeInOut(duration: 0.4))
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
