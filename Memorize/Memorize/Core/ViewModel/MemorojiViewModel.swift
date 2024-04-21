//
//  EmojiMemoryGameViewModel.swift
//  Memorize
//
//  Created by Uri on 9/3/24.
//

import SwiftUI

final class MemorojiViewModel: ObservableObject {
    
    typealias Card = MemorizeGame<String>.Card
    
    var memorizeDecks = MemorizeDeck.builtins
    
    private static func createMemorizeGame(memorizeDecks: [MemorizeDeck], deckIndex: Int) -> MemorizeGame<String> {
        return MemorizeGame(numberOfPairsOfCards: memorizeDecks[deckIndex].emojis.count) { pairIndex in
            if memorizeDecks[deckIndex].emojis.indices.contains(pairIndex) {
                return memorizeDecks[deckIndex].emojis[pairIndex]
             } else {
                 return "⁉️"
             }
         }
    }
    
    // MARK: - MemorizeDeck, starts with Halloween
    @Published var deckIndex = 5
    
    // MARK: - MemorizeGame
    @Published private var model = createMemorizeGame(memorizeDecks: MemorizeDeck.builtins, deckIndex: 5)
    
    var cards: Array<Card> {
        model.cards
    }
    
    var score: Int {
        model.score
    }
    
    var matches: Int {
        model.matches
    }
    
    @Published var color: Color = .orange
    
    func isGameFinished() -> Bool {
        if matches == memorizeDecks[deckIndex].emojis.count {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Scoreboard
    @Published var scoreboard: [Scorecard] = []
    private var scoreboardLimit: Int = 10
    
    init() {
        scoreboard = getScoreboard()
        addCustomDeckToDefaultDecks()
    }
    
    @Published var showScoreSavedConfirmation: Bool = false
    
    func saveScore(player: String, deck: String, matches: Int, score: Int) {
        if isScoreboardFull() && isNewHighScore(score: score) {
            removeLowestScore()
        }
        scoreboard.append(Scorecard(player: player, deck: deck, matches: matches, score: score))
        encodeAndSaveScoreboard()
        debugPrint("new score saved: \(score)")
        debugPrint("scoreboard count: \(scoreboard.count)")
    }
    
    func isNewHighScore(score: Int) -> Bool {
        if scoreboard.isEmpty {
            return true
        }
        return scoreboard.contains { $0.score < score }
    }
    
    func isScoreboardFull() -> Bool {
        return scoreboard.count == scoreboardLimit
    }
    
    func resetScoreboard() {
        scoreboard.removeAll()
        encodeAndSaveScoreboard()
    }
    
    private func removeLowestScore() {
        guard let lowestScore = scoreboard.min(by: { $0.score < $1.score })?.score else { return }
        if let index = scoreboard.firstIndex(where: { $0.score == lowestScore }) {
            scoreboard.remove(at: index)
        }
    }
    
    private func encodeAndSaveScoreboard() {
        if let encoded = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encoded, forKey: "scoreboard")
        }
    }
    
    private func getScoreboard() -> [Scorecard] {
        if let scoreboardData = UserDefaults.standard.object(forKey: "scoreboard") as? Data {
            if let scoreboard = try? JSONDecoder().decode([Scorecard].self, from: scoreboardData) {
                return scoreboard
            }
        }
        return []
    }
    
    // MARK: - Custom Deck
    var customDeck: MemorizeDeck? = nil
    
    func saveCustomDeck(name: String, emojis: [String]) {
        removeExistingCustomDeck()
        customDeck = MemorizeDeck(name: name, emojis: emojis)
        encodeAndSaveCustomDeck()
        debugPrint("custom deck saved with name \(name) and emojis \(emojis.count)")
    }
    
    private func encodeAndSaveCustomDeck() {
        if let encoded = try? JSONEncoder().encode(customDeck) {
            UserDefaults.standard.set(encoded, forKey: "customDeck")
        }
    }
    
    private func getCustomDeck() -> MemorizeDeck? {
        if let customDeckData = UserDefaults.standard.object(forKey: "customDeck") as? Data {
            if let customDeck = try? JSONDecoder().decode(MemorizeDeck.self, from: customDeckData) {
                return customDeck
            }
        }
        return nil
    }
    
    private func addCustomDeckToDefaultDecks() {
        if let loadedCustomDeck = getCustomDeck() {
            customDeck = loadedCustomDeck
            memorizeDecks.append(loadedCustomDeck)
        }
    }
    
    func removeExistingCustomDeck() {
        if memorizeDecks.count == 10 {
            debugPrint("memorizedecks count before removing: \(memorizeDecks.count)")
            memorizeDecks.removeLast()
            debugPrint("memorizedecks count after removing: \(memorizeDecks.count)")
        }
    }
    
    
    // MARK: - Intents
    func shuffle() {
        model.shuffle()
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func resetGame() {
        model.resetGame()
        model = MemorojiViewModel.createMemorizeGame(memorizeDecks: memorizeDecks, deckIndex: deckIndex)
    }
}