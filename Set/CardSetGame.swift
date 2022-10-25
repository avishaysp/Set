//
//  CardSetGame.swift
//  Set 
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import SwiftUI

class CardSetGame: ObservableObject {
    typealias SetGameModel = SetGame<Color, Shape, Style ,Int>
    typealias Card = SetGame<Color, Shape, Style ,Int>.Card
    var cards = [Card]()
    
    var cardsToDisplay: [Card] {
        model.cardsToDisplay
    }
    
    
    func canDrawMore() -> Bool {
        model.canDrawMore()
    }
    
    @Published private var model: SetGameModel
    
    init() {
        var id = 0
        for color in CardSetGame.colors {
            for shape in CardSetGame.Shape.allCases {
                for style in CardSetGame.Style.allCases {
                    for number in 1...3 {
                        cards.append(Card(cardContent1: color, cardContent2: shape, cardContent3: style, cardContent4: number, id: id))
                        id += 1
                    }
                }
            }
        }
        cards.shuffle()
        model = SetGameModel(cards, nuemberOfCardsToDisplay: CardSetGame.numberOfCardsToDsiplay)
        
    }
    
    // MARK: - Data
    
    static let numberOfCardsToDsiplay = 12
    
    static let colors = [Color.red, Color.purple, Color.green]
    
    enum Shape: CaseIterable {
        case circle, triangle, square
    }
    enum Style: CaseIterable {
        case blank, half, full
    }
    // last element in each tuple is the suited unicode
    static private let shapesList: [(Shape, Style , Character)] =
    [
        (.circle, .blank, "◯"),   (.circle, .half, "◑"),   (.circle, .full, "●"),
        (.triangle, .blank, "△"), (.triangle, .half, "◮"), (.triangle, .full, "▲"),
        (.square, .blank, "□"),   (.square, .half, "◨"),   (.square, .full, "■")
    ]

    
    //MARK: - Get Data
    
    private static func matchingUnicodeOf(_ shape: Shape, _ style: Style) -> Character? {
        if let index = shapesList.firstIndex(where: { $0.0 == shape && $0.1 == style }) {
            return shapesList[index].2
        }
        return nil
    }
    
    static func matchingValueOf(_ card: Card) -> String? {
        if let uniCodeSymbol = matchingUnicodeOf(card.cardContent2, card.cardContent3){
            var arr: [Character] = []
            for _ in 0..<card.cardContent4 {
                arr.append(uniCodeSymbol)
                arr.append(" ")
            }
            arr.removeLast()
            return String(arr)
        }
        return nil
    }
    
    func highlightColor(of card: Card) -> Color {
        if model.numberOfChosenCards == 3 && card.isChosen {
            return model.chosenCardsMatch() ? .green : .red
        }
        if card.isHinted {
            return .orange
        }
        if !model.someoneIsPlaying {
            return .gray
        }
        switch (card.isChosen, card.isMatched) {
            case (true, true):
                return .green
            case (true, false):
                return .yellow
            default:
            return .cyan
        }
    }
    
    func canSet() -> Bool {
        model.canSet()
    }
    
    var isHinting: Bool {
        model.isHinting
    }
    
    func nextChooseChangesLayout() -> Bool {
        model.nextChooseChangesLayout()
    }
    
    var player1Score: Int {
        model.player1.score
    }
    
    var player2Score: Int {
        model.player2.score
    }
    
    var playerPlaying: Int {
        model.playerPlaying
    }
    
    var someoneIsPlaying: Bool {
        model.someoneIsPlaying
    }
    
    func over() -> Bool {
        model.gameOver()
    }
    
    // MARK: - Intents
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func drawThreeCards() {
        model.drawThreeCards()
    }
    func restart() {
        cards.shuffle()
        model = SetGameModel(cards, nuemberOfCardsToDisplay: CardSetGame.numberOfCardsToDsiplay)
        print("game restarted")
    }
    
    func hint(by playerNumber: Int) {
        model.Hint(by: playerNumber)
    }
    
    func stopHinting() {
        model.stopHinting()
    }
    
    func pressSet(byPlayer playerNumber: Int) {
        assert([1, 2].contains(playerNumber))
        if model.playerPlaying == 0 {
            model.declareSet(by: playerNumber)
        } else {
            model.undeclareSet()
        }
    }
}


