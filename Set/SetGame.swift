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
    var score: Int
    
    
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
        while result.count < numberOfCardsToDisplay {
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
        score = 0
    }
    
    //MARK: - Functionality
        
    mutating func choose(_ card: Card) {
        if let indexOfChosenCard = cards.firstIndex(where: {$0.id == card.id}) {
            if !chosenCardsIndecies.contains(indexOfChosenCard) && chosenCardsIndecies.count == 2 {
                if threeCardsMatch(cards[chosenCardsIndecies[0]], cards[chosenCardsIndecies[1]], cards[indexOfChosenCard]) {
                    cards[chosenCardsIndecies[0]].isMatched = true
                    cards[chosenCardsIndecies[1]].isMatched = true
                    cards[indexOfChosenCard].isMatched = true
                    print("it's a match!")
                    score += 3
                    chosenCardsIndecies = []
                    numberOfCardsToDisplay -= 3
                    if numberOfCardsToDisplay < 12 {
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
        stopHinting()
        print("Chosen Cards Indecies: \(chosenCardsIndecies)")
    }
    
    mutating func drawThreeCards() {
        /* Changes the cards displayed by mutating their display indecies.
           Utelizes the funcs getFirstThreeEmptyDisplayIndecies() and insertThreeCardsTo(index0: Int, index1: Int, index2: Int) */
        numberOfCardsToDisplay += 3
        stopHinting()
        print("three cards drawn")
    }
    
    mutating func Hint() {
        if canHint() {
            if !chosenCardsIndecies.isEmpty {
                if chosenCardsIndecies.count <= 1 {
                    cards[chosenCardsIndecies[0]].isChosen = false
                } else if chosenCardsIndecies.count <= 2 {
                    cards[chosenCardsIndecies[1]].isChosen = false
                } else if chosenCardsIndecies.count <= 3 {
                    cards[chosenCardsIndecies[2]].isChosen = false
                }
                chosenCardsIndecies = []
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
        }
    }
    
    mutating func stopHinting() {
        cards.indices.forEach { cards[$0].isHinted = false }
        isHinting = false
        print("hinting stoped")
    }
    

    //MARK: - Get Data
    
    func canDrawMore() -> Bool {
        numberOfCardsToDisplay + cards.filter({ $0.isMatched }).count < cards.count
    }
    
    func canHint() -> Bool {
        threeDisplayedCardsThatMatchByID() != nil
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
}
