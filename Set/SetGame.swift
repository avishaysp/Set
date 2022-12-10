//
//  SetGame.swift
//  Set
//
//  Created by Avishay Spitzer on 29/07/2022.
//

import Foundation
import SwiftUI

struct SetGame<CardContent1: Equatable, CardContent2: Equatable, CardContent3: Equatable, CardContent4: Equatable> {
    
    
    //MARK: - Parameters
    
    private(set) var cards: [Card]
    var numberOfCardsToDisplay: Int
    var isHinting: Bool
    private(set) var player1: Player
    private(set) var player2: Player
    
    var playerPlaying: Int? {
        get {
            switch (player1.isPlaying, player2.isPlaying) {
            case (true, true):
                assertionFailure()
            case (false, false):
                return nil
            default:
                return player1.isPlaying ? 1 : 2
            }
            return nil
        }
        set {
            assert([0, 1, 2].contains(newValue))
            if (newValue == 1 && player2.isPlaying) || (newValue == 2 && player1.isPlaying) { assertionFailure() }
            else if newValue == 1 { player1.isPlaying = true }
            else if newValue == 2 { player2.isPlaying = true }
            else {
                // must be zero
                player1.isPlaying = false
                player2.isPlaying = false
            }
        }
    }
    
    var someoneIsPlaying: Bool {
        playerPlaying != nil
    }
    
    private var chosenCardsIndecies: [Int] {
        get { cards.indices.filter({ cards[$0].isChosen }) }
        set {
            cards.indices.forEach { cards[$0].isChosen = false }
            newValue.forEach { cards[$0].isChosen = true }
        }
    }
    
    var numberOfChosenCards: Int {
        chosenCardsIndecies.count
    }
    
    var cardsToDisplay: [Card] {
        var result = [Card]()
        var i = 0
        while result.count < numberOfCardsToDisplay && i < cards.count {
            if cards[i].isMatched {
                i += 1
            } else {
                result.append(cards[i])
                i += 1
            }
        }
        return result
    }
    
    init(_ cards: [Card], nuemberOfCardsToDisplay: Int) {
        self.cards = cards
        self.numberOfCardsToDisplay = nuemberOfCardsToDisplay
        isHinting = false
        player1 = Player(id: 1, score: 0)
        player2 = Player(id: 2, score: 0)
    }
    
    //MARK: - Functionality
        
    mutating func choose(_ card: Card) {
        assert([1, 2].contains(playerPlaying))
        if let indexOfChosenCard = cards.firstIndex(where: {$0.id == card.id}) {
            if !chosenCardsIndecies.contains(indexOfChosenCard) && chosenCardsIndecies.count == 2 {
                if threeCardsMatch(cards[chosenCardsIndecies[0]], cards[chosenCardsIndecies[1]], cards[indexOfChosenCard]) {
                    cards[chosenCardsIndecies[0]].isMatched = true
                    cards[chosenCardsIndecies[1]].isMatched = true
                    cards[indexOfChosenCard].isMatched = true
                    print("it's a match!")
                    if playerPlaying == 1 { player1.score += 3}
                    else { player2.score += 3 }
                    playerPlaying = 0
                    chosenCardsIndecies = []
                    numberOfCardsToDisplay -= 3
                    if numberOfCardsToDisplay < 12 && numberOfCardsToDisplay > 0 {
                        drawThreeCards()
                    }
                } else {
                    cards[indexOfChosenCard].isChosen.toggle()
                }
            } else if chosenCardsIndecies.count == 3 {
                chosenCardsIndecies = []
                cards[indexOfChosenCard].isChosen = true
            } else { cards[indexOfChosenCard].isChosen.toggle() }
        } else { assertionFailure() }
        if isHinting {
            stopHinting()
        }
        print("Chosen Cards Indecies: \(chosenCardsIndecies)")
    }
    
    mutating func drawThreeCards() {
        /* Changes the cards displayed by mutating their display indecies.
           Utelizes the funcs getFirstThreeEmptyDisplayIndecies() and insertThreeCardsTo(index0: Int, index1: Int, index2: Int) */
        numberOfCardsToDisplay += 3
        if isHinting {
            stopHinting()
        }
        print("three cards drawn")
    }
    
    mutating func resetChosenCards() {
        chosenCardsIndecies = []
    }
    
    mutating func Hint(by playerNumber: Int) {  // asuming there is a set when called
        assert([1, 2].contains(playerNumber))
        if !chosenCardsIndecies.isEmpty {
            if chosenCardsIndecies.count <= 1 {
                cards[chosenCardsIndecies[0]].isChosen = false
            } else if chosenCardsIndecies.count <= 2 {
                cards[chosenCardsIndecies[1]].isChosen = false
            } else if chosenCardsIndecies.count <= 3 {
                cards[chosenCardsIndecies[2]].isChosen = false
            }
        }
        let randomIndex = [0, 1, 2].randomElement()!
        switch randomIndex {
        case 0:
            cards[cards.firstIndex { $0.id == threeDisplayedCardsThatMatchByID()!.0 }!].isHinted = true
        case 1:
            cards[cards.firstIndex { $0.id == threeDisplayedCardsThatMatchByID()!.1 }!].isHinted = true
        default:
            cards[cards.firstIndex { $0.id == threeDisplayedCardsThatMatchByID()!.2 }!].isHinted = true
        }
        isHinting = true
        if playerNumber == 1 {
            player1.score -= 2
        } else {
            player2.score -= 2
        }
        print("hint given")
    }
    
    mutating func stopHinting() {
        cards.indices.forEach { cards[$0].isHinted = false }
        isHinting = false
        print("hinting stoped")
    }
    
    mutating func declareSet(by playerNumber: Int) {
        assert([1, 2].contains(playerNumber))
        playerPlaying = playerNumber
        print("now playing: \(playerPlaying!)")
    }
    
    mutating func undeclareSet() {
        playerPlaying = 0
        print("no one is playing")
    }

    //MARK: - Get Data
    
    func canDrawMore() -> Bool {
        numberOfCardsToDisplay + cards.filter({ $0.isMatched }).count < cards.count
    }
    
    func canSet() -> Bool {
        threeDisplayedCardsThatMatchByID() != nil
    }
    
    func gameOver() -> Bool {
        numberOfCardsToDisplay == 0
    }
    
    func threeDisplayedCardsThatMatchByID() -> (Int, Int, Int)? {
        for i in 0..<min(numberOfCardsToDisplay, cardsToDisplay.count) {
            for j in i + 1..<min(numberOfCardsToDisplay, cardsToDisplay.count) {
                for k in j + 1..<min(numberOfCardsToDisplay, cardsToDisplay.count) {
                    if threeCardsMatch(cardsToDisplay[i], cardsToDisplay[j], cardsToDisplay[k]) {
                        return (cardsToDisplay[i].id, cardsToDisplay[j].id, cardsToDisplay[k].id)
                    }
                }
            }
        }
        return nil
    }
    
    func nextChooseChangesLayout() -> Bool {
        chosenCardsIndecies.count == 3 && threeCardsMatch(cards[chosenCardsIndecies[0]], cards[chosenCardsIndecies[1]], cards[chosenCardsIndecies[2]])
    }
    
    // MARK: - Card
    
    struct Card: Identifiable {
        let cardContent1: CardContent1
        let cardContent2: CardContent2
        let cardContent3: CardContent3
        let cardContent4: CardContent4
        var isChosen = false
        var isMatched = false
        let id: Int
        var isHinted = false
    }
    
    private func threeCardsMatch(_ first: Card, _ second: Card, _ third: Card) -> Bool {
        if !allThreeDiffer(first.cardContent1, second.cardContent1, third.cardContent1) &&
            !(allThreeEquale(first.cardContent1, second.cardContent1, third.cardContent1)) {
            return false
        }
        if !allThreeDiffer(first.cardContent2, second.cardContent2, third.cardContent2) &&
            !(allThreeEquale(first.cardContent2, second.cardContent2, third.cardContent2)) {
            return false
        }
        if !allThreeDiffer(first.cardContent3, second.cardContent3, third.cardContent3) &&
            !(allThreeEquale(first.cardContent3, second.cardContent3, third.cardContent3)) {
            return false
        }
        if !allThreeDiffer(first.cardContent4, second.cardContent4, third.cardContent4) &&
            !(allThreeEquale(first.cardContent4, second.cardContent4, third.cardContent4)) {
            return false
        }
        return true
    }
    
    private func allThreeDiffer<CardContentProperty: Equatable>(_ first: CardContentProperty, _ second: CardContentProperty, _ third: CardContentProperty) -> Bool {
        (first != second) && (second != third) && (third != first)
    }
    
    private func allThreeEquale<CardContentProperty: Equatable>(_ first: CardContentProperty, _ second: CardContentProperty, _ third: CardContentProperty) -> Bool {
        (first == second) && (second == third) && (third == first)
    }
    
    func chosenCardsMatch() -> Bool {
        return threeCardsMatch(cards[chosenCardsIndecies[0]], cards[chosenCardsIndecies[1]], cards[chosenCardsIndecies[2]])

    }
    
    //MARK: - Player
    
    struct Player: Identifiable {
        let id: Int
        var score: Int
        var isPlaying = false
    }
}
