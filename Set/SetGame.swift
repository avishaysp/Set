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
    private var nilCard: Card
    private(set) var numberOfCardsToDisplay: Int
    
    
    private var chosenCardsIndexes: [Int] {
        get { cards.indices.filter({ cards[$0].isChosen }) }
        set {
            cards.indices.forEach { cards[$0].isChosen = false }
            newValue.forEach { cards[$0].isChosen = true }
        }
    }
    
    var cardsToDisplay: [Card] {
        var result = [Card]()
        for i in 0..<numberOfCardsToDisplay {
            if let index = indexInCardsByDisplayIndex(displayIndex: i) {
                result.append(cards[index])
            } else {
                result.append(nilCard)
            }
        }
        print("")
        print(result)
        return result
    }
    
    init(_ cards: [Card], nuemberOfCardsToDisplay: Int, nilCard: Card) {
        self.cards = cards
        self.nilCard = nilCard
        self.numberOfCardsToDisplay = nuemberOfCardsToDisplay
        for i in 0..<min(cards.count, numberOfCardsToDisplay) {
            self.cards[i].displayIndex = i
        }
    }
    
    //MARK: - Functionality
    
    //Cards
    
    mutating func choose(_ card: Card) {
        if let indexOfChosenCard = cards.firstIndex(where: {$0.id == card.id}) {
            switch (chosenCardsIndexes.contains(indexOfChosenCard), chosenCardsIndexes.count) {
            case (true, 3):
                if threeCardsMatch(cards[chosenCardsIndexes[0]], cards[chosenCardsIndexes[1]], cards[chosenCardsIndexes[2]]) {
                    cards[chosenCardsIndexes[0]].displayIndex = nil
                    cards[chosenCardsIndexes[1]].displayIndex = nil
                    cards[chosenCardsIndexes[2]].displayIndex = nil
                }
                chosenCardsIndexes = []
//                print("3 cards drawn")
            case (false, 3):
                if threeCardsMatch(cards[chosenCardsIndexes[0]], cards[chosenCardsIndexes[1]], cards[chosenCardsIndexes[2]]) {
                    cards[chosenCardsIndexes[0]].displayIndex = nil
                    cards[chosenCardsIndexes[1]].displayIndex = nil
                    cards[chosenCardsIndexes[2]].displayIndex = nil
                }
                chosenCardsIndexes = []
                cards[indexOfChosenCard].isChosen = true
//                print("3 cards drawn")
            case (false, 2):
                if threeCardsMatch(cards[chosenCardsIndexes[0]], cards[chosenCardsIndexes[1]], cards[indexOfChosenCard]) {
                    cards[chosenCardsIndexes[0]].isMatched = true
                    cards[chosenCardsIndexes[1]].isMatched = true
                    cards[indexOfChosenCard].isMatched = true
                }
                cards[indexOfChosenCard].isChosen = true
            default:
                cards[indexOfChosenCard].isChosen.toggle()
            }
        } else { assertionFailure() }
    }
    
    mutating func drawThreeCards() {
        /* Changes the cards displayed by mutating their display indecies.
           Utelizes the funcs getFirstThreeEmptyDisplayIndecies() and insertThreeCardsTo(index0: Int, index1: Int, index2: Int) */
        if let indecies = getFirstThreeEmptyDisplayIndecies() {
            insertThreeCardsTo(index0: indecies.0, index1: indecies.1, index2: indecies.2)
        } else {
            numberOfCardsToDisplay += 3
            insertThreeCardsTo(index0: numberOfCardsToDisplay - 3, index1: numberOfCardsToDisplay - 2, index2: numberOfCardsToDisplay - 1)
        }
        print("three cards drawn. suposed to apear on screen")
    }
    
    private mutating func insertThreeCardsTo(index0: Int, index1: Int, index2: Int) {
        let indexesOfDrawnCards = drawThreeIndecies()
        if let index = indexesOfDrawnCards.2 {
            assert(cards[index].displayIndex == nil)
            cards[index].displayIndex = index2
        }
        if let index = indexesOfDrawnCards.1 {
            assert(cards[index].displayIndex == nil)
            cards[index].displayIndex = index1
        }
        if let index = indexesOfDrawnCards.0 {
            assert(cards[index].displayIndex == nil)
            cards[index].displayIndex = index0
        }
    }
    

    
    //MARK: - Get Data
    
    func canDrawMore() -> Bool {
        !cards.filter({ $0.displayIndex == nil && !$0.isMatched }).isEmpty
    }
    
    private func getFirstThreeEmptyDisplayIndecies() -> (Int, Int, Int)? {
        let nilCardsIndecies = cardsToDisplay.indices.filter { cardsToDisplay[$0].displayIndex == nil }
        if nilCardsIndecies.count > 0 {
            return (nilCardsIndecies[0], nilCardsIndecies[1], nilCardsIndecies[2])
        }
        return nil
    }
    
    private func drawThreeIndecies() -> (Int?, Int?, Int?) {
        var cardsNotDisplayed = cards.indices.filter( { cards[$0].displayIndex == nil && cards[$0].isMatched == false } ).shuffled()
        let index1 = cardsNotDisplayed.popLast()
        let index2 = cardsNotDisplayed.popLast()
        let index3 = cardsNotDisplayed.popLast()
        return (index1, index2, index3)
    }
    
    private func indexInCardsByDisplayIndex(displayIndex: Int) -> Int? {
        cards.indices.firstIndex { cards[$0].displayIndex == displayIndex }
    }
    
    // MARK: - Card
    
    struct Card: Identifiable {
        let cardContent1: CardContent1
        let cardContent2: CardContent2
        let cardContent3: CardContent3
        let cardContent4: CardContent4
        var isChosen = false
        var isMatched = false
        var displayIndex: Int? // nil until displayed for the first time
        let id: Int
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
}
