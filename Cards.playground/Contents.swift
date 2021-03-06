// A Swift-only playground that I made to help me understand how to implement generators for Swift enum types.
//
// Published under the MIT License (MIT)
//
// Copyright © 2014 Sailmaker Systems Ltd. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Swift
import Foundation // needed only for arc4random_uniform()

// MARK: - Rank

/// Represents the rank of a traditional Western playing card
enum Rank: Int, SequenceType, Printable {
    case Ace = 1
    case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King
    
    init() {
        self = .Ace
    }
    
    func simpleDescription() -> String {
        // real-world implementations would of course localize the strings
        switch self {
        case .Ace:
            return "ace"
        case .Jack:
            return "jack"
        case .Queen:
            return "queen"
        case .King:
            return "king"
        default:
            return String(self.rawValue)
        }
    }
    
    var symbol: String {
        // real-world implementations would of course localize the strings
        switch self {
        case .Ace:
            return "A"
        case .Jack:
            return "J"
        case .Queen:
            return "Q"
        case .King:
            return "K"
        default:
            return String(self.rawValue)
        }
    }
    
    var isFaceCard: Bool {
        switch self {
        case .Jack, .Queen, .King:
            return true
        default:
            return false
        }
    }
    
    var description: String {
        return "Rank: \(symbol)"
    }
    
    func next() -> Rank? {
        switch self {
        case .King:
            return nil
        default:
            let rawVal = self.rawValue
            return Rank(rawValue: rawVal + 1)
        }
    }
    
    typealias Generator = RankGenerator
    
    func generate() -> RankGenerator {
        return RankGenerator()
    }
    
    struct RankGenerator: GeneratorType {
        var rank: Rank? = Rank()
        
        mutating func next() -> Rank? {
            let currentRank = rank
            rank = rank?.next()
            return currentRank
        }
    }
    
    func ranking(acesHigh: Bool = false) -> Int {
        if acesHigh && self == .Ace {
            return Rank.King.rawValue + 1
        }
        return self.rawValue
    }
    
    func compareTo(rhs:Rank, acesHigh: Bool = false) -> Int {
        let lhsRanking = self.ranking(acesHigh: acesHigh)
        let rhsRanking = rhs.ranking(acesHigh: acesHigh)
        if lhsRanking < rhsRanking {
            return -1
        } else if lhsRanking == rhsRanking {
            return 0
        } else {
            return 1
        }
    }
}

// MARK: Rank tests
let rankString = reduce(Rank(), "") {$0 + $1.symbol}
rankString
assert(rankString == "A2345678910JQK", "The ranks are ordered from Ace to King")

assert(Rank.King.isFaceCard, "A King is a face card")
let faceCards = filter(Rank()) {$0.isFaceCard}
let faceCardsString = faceCards.reduce("") {$0 + $1.symbol}
faceCardsString
assert(faceCardsString == "JQK", "The face cards from Jack to King")

assert(!Rank.Ace.isFaceCard, "An Ace is a spot card")
let spotCards = filter(Rank()) {!$0.isFaceCard}
let spotCardsString = spotCards.reduce("") {$0 + $1.symbol}
spotCardsString
assert(spotCardsString == "A2345678910", "The spot cards from Ace to Ten")

assert(Rank.Five.simpleDescription() == "5", "A five card is described as '5'")
assert(Rank.King.symbol == "K", "A King card is described as 'K'")
assert(Rank.Five.compareTo(.Five) == 0, "Equal ranks compare equal")
assert(Rank.Ace.compareTo(.King, acesHigh: false) == -1, "King beats Ace when Aces are low")
assert(Rank.King.compareTo(.Ace, acesHigh: false) == 1, "King beats Ace when Aces are low")
assert(Rank.Ace.compareTo(.King, acesHigh: true) == 1, "Ace beats King when Aces are high")
assert(Rank.King.compareTo(.Ace, acesHigh: true) == -1, "Ace beats King when Aces are high")
assert(Rank.Ace.compareTo(.King) == -1, "Default is Aces low")
assert(Rank.King.compareTo(.Ace) == 1, "Default is Aces low")

// MARK: - Suit

/// Represents the suit of a traditional Western playing card using the ranking used in Bridge
// For learning purposes, this enum isn't an Int, even though that might be a more efficient implementation.
enum Suit: SequenceType, Printable {
    case Spades, Hearts, Diamonds, Clubs
    
    init() {
        self = .Spades
    }
    
    func simpleDescription() -> String {
        // real-world implementations would of course localize the strings
        switch self {
        case .Spades:
            return "spades"
        case .Hearts:
            return "hearts"
        case .Diamonds:
            return "diamonds"
        case .Clubs:
            return "clubs"
        }
    }
    
    var symbol: String {
        switch self {
        case .Spades:
            return "♠️"
        case .Hearts:
            return "♥️"
        case .Diamonds:
            return "♦️"
        case .Clubs:
            return "♣️"
        }
    }
    
    var color: String {
        // real-world implementations would of course use another enum
        switch self {
        case .Spades, .Clubs:
            return "black"
        case .Hearts, .Diamonds:
            return "red"
        }
    }
    
    func next() -> Suit? {
        // using the ranking used in Bridge
        switch self {
        case .Spades:
            return .Hearts
        case .Hearts:
            return .Diamonds
        case .Diamonds:
            return .Clubs
        case .Clubs:
            return nil
        }
    }
    
    typealias Generator = SuitGenerator
    
    func generate() -> SuitGenerator {
        return SuitGenerator()
    }
    
    struct SuitGenerator: GeneratorType {
        // using the ranking used in Bridge
        var suit: Suit? = Suit()
        
        mutating func next() -> Suit? {
            let currentSuit = suit
            suit = suit?.next()
            return currentSuit
        }
    }
    
    func outRanks(rhs: Suit) -> Bool {
        // using the ranking used in Bridge
        if self == rhs {
            // no suit outranks itself
            return false
        }
        
        // having dispensed with the equality case, let's do the comparisons
        switch self {
        case .Spades:
            // Spades outrank all
            return true
        case .Hearts:
            // Hearts outrank all but Spades
            return rhs != .Spades
        case .Diamonds:
            // Diamonds outrank all but Spades and Hearts
            return rhs != .Spades && rhs != .Hearts
        case .Clubs:
            // Clubs outrank nothing
            return false
        }
    }
    
    var description: String {
        return "Suit: \(symbol)"
    }
}

// MARK: Suit tests

let hearts = Suit.Hearts
assert(hearts.simpleDescription() == "hearts")
assert(hearts.color == "red")
assert(hearts.symbol == "♥️")

// pay attention to the ! signs in the following tests
assert(!Suit.Spades.outRanks(Suit.Spades))
assert(Suit.Spades.outRanks(Suit.Hearts))
assert(Suit.Spades.outRanks(Suit.Diamonds))
assert(Suit.Spades.outRanks(Suit.Clubs))

assert(!Suit.Hearts.outRanks(Suit.Spades))
assert(!Suit.Hearts.outRanks(Suit.Hearts))
assert(Suit.Hearts.outRanks(Suit.Diamonds))
assert(Suit.Hearts.outRanks(Suit.Clubs))

assert(!Suit.Diamonds.outRanks(Suit.Spades))
assert(!Suit.Diamonds.outRanks(Suit.Hearts))
assert(!Suit.Diamonds.outRanks(Suit.Diamonds))
assert(Suit.Diamonds.outRanks(Suit.Clubs))

assert(!Suit.Clubs.outRanks(Suit.Spades))
assert(!Suit.Clubs.outRanks(Suit.Hearts))
assert(!Suit.Clubs.outRanks(Suit.Diamonds))
assert(!Suit.Clubs.outRanks(Suit.Clubs))

let suitString = reduce(Suit(), "", {$0 + $1.symbol})
suitString
assert(suitString == "♠️♥️♦️♣️", "suits should appear in Bridge order")

let redSuits = filter(Suit()) {$0.color == "red"}
let redSuitSymbols = redSuits.reduce("") {$0 + $1.symbol}
redSuitSymbols
assert(redSuitSymbols == "♥️♦️", "only red suits, in Bridge order")

// MARK: - Card

/// Represents a traditional Western playing card (without Jokers)
struct Card : Comparable, Hashable, Printable {
    let rank: Rank
    let suit: Suit
    
    func simpleDescription() -> String {
        // real-world implementations would of course localize the strings
        return "The \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }
    
    var symbol: String {
        return rank.symbol + suit.symbol
    }
    
    var description: String {
        return "Card: \(symbol)"
    }
    
    func outRanks(otherCard: Card, acesHigh: Bool = false) -> Bool {
        let rankComparison = self.rank.compareTo(otherCard.rank, acesHigh: acesHigh)
        if rankComparison == 1 {
            return true
        } else if rankComparison == -1 {
            return false
        } else {
            return suit.outRanks(otherCard.suit)
        }
    }
    
    func equals(otherCard: Card) -> Bool {
        return rank == otherCard.rank && suit == otherCard.suit
    }
    
    // since I implement equals, do I also need to implement hashValue? Unclear, but I'll do it anyway.
    var hashValue: Int { 
        get {
            return self.symbol.hashValue
        }
    }
    
    var isFaceCard: Bool {
        return self.rank.isFaceCard
    }
    
    static func fullDeck() -> [Card] {
        // *** This is the real reason why I wrote this playground: the ability to use generators on suit and rank ***
        var deck = [Card]()
        for suit in Suit() {
            for rank in Rank() {
                let card = Card(rank: rank, suit: suit)
                deck.append(card)
            }
        }
        return deck
    }
}

func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.equals(rhs)
}

func < (lhs: Card, rhs: Card) -> Bool {
    return rhs.outRanks(lhs)
}

// MARK: Card and deck tests

let deck = Card.fullDeck()
assert(deck.count == 52, "A full deck with no Jokers has 52 cards")
let card36 = deck[36]
let jackOfDiamonds = Card(rank: .Jack, suit: .Diamonds)
assert(jackOfDiamonds.equals(card36), "card 36 is the Jack of dimaonds")
assert(jackOfDiamonds == card36, "the == operator works too")
assert(jackOfDiamonds.description == card36.description, "they have the same description too")
assert( !(jackOfDiamonds < card36), "they sort equally")
assert( !(jackOfDiamonds > card36), "they sort equally")

assert(jackOfDiamonds.hashValue == "J♦️".hashValue, "hash value is built from symbol")

let decksymbols = deck.map({$0.symbol})
decksymbols // for visual inspection in the Playground

let kingOfSpades = Card(rank: .King, suit: .Spades)
let kingOfDiamonds = Card(rank: .King, suit: .Diamonds)

// test the auto-genreated inequality operators
assert(!(kingOfSpades == kingOfDiamonds), "They are not the same")
assert(kingOfSpades != kingOfDiamonds, "They are not the same")
assert(!(kingOfSpades < kingOfDiamonds), "King of Spades beats King of Diamonds")
assert(!(kingOfSpades <= kingOfDiamonds), "King of Spades beats King of Diamonds")
assert(kingOfSpades > kingOfDiamonds, "King of Spades beats King of Diamonds")
assert(kingOfSpades >= kingOfDiamonds, "King of Spades beats King of Diamonds")
assert(kingOfSpades == kingOfSpades, "Same card")
assert(!(kingOfSpades > kingOfSpades), "Same card")
assert(!(kingOfSpades.outRanks(kingOfSpades, acesHigh: false)), "Same card")

let deckAcesLow = sorted(deck, >)
let deckSymbols = deckAcesLow.map({$0.symbol})
deckSymbols // for visual inspection in the Playground
deckSymbols.reverse()

let deckAcesHigh = sorted(deck) {
    card1, card2 in 
    return card1.outRanks(card2, acesHigh: true) 
}
let deckSymbolsAceHigh = deckAcesHigh.map{$0.symbol}
deckSymbolsAceHigh // for visual inspection in the Playground
deckSymbolsAceHigh.reverse() // for visual inspection in the Playground

let faceCardsDeck = deck.filter{$0.isFaceCard}
assert(faceCardsDeck.count == 12, "There are 12 face cards in a standard deck")
assert(deck.count == 52, "Original desk not stripped")
let faceCardSymbols = faceCardsDeck.reduce(""){$0 + $1.symbol}
faceCardSymbols

// a Piquet deck omits cards of rank 2...6 <http://en.wikipedia.org/wiki/Piquet>
let piquetDeck = deck.filter {
    (card: Card) in
    // an alternative to switching on raw values is to make Rank Comparable, but that conflicts with making the acesHigh rule explicit
    switch card.rank.rawValue {
    case Rank.Two.rawValue...Rank.Six.rawValue:
        return false
    default:
        return true
    }
}
assert(piquetDeck.count == 32, "There are 32 cards in a Piquet deck")
let piquetDeckSymbols = piquetDeck.reduce(""){$0 + $1.symbol}
piquetDeckSymbols


// MARK: - Shuffle

// Fisher–Yates shuffle <http://en.wikipedia.org/wiki/Fisher-Yates_Shuffle> adapted from
// <http://iosdevelopertips.com/swift-code/swift-shuffle-array-type.html> with j being "let" not "var"
func shuffleArray<T>(inout array: Array<T>) -> Array<T> {
    for var index = array.count - 1; index > 0; index-- {
        // Random int from 0 to index-1
        let j = Int(arc4random_uniform(UInt32(index-1)))
        
        // Swap two array elements
        // Notice '&' required as swap uses 'inout' parameters
        swap(&array[index], &array[j])
    }
    return array
}

func shuffledArray<T>(array: Array<T>) -> Array<T> {
    var shuffledArray = array
    return shuffleArray(&shuffledArray)
}

// MARK: Shuffle tests
// Not testing the stochastic quality of the shuffle algo, just that it isn't changing the array passed in.

let shuffledDeck = shuffledArray(deck)
let decksymbols2 = deck.map {$0.symbol }
decksymbols2
assert(decksymbols == decksymbols2, "original deck not shuffled")
let shuffledSymbols = shuffledDeck.map {$0.symbol}
shuffledSymbols

let resortedDeck = shuffledDeck.sorted(<)
let originalSortedDeck = deck.sorted(<)
let resortedDeckSymbols = resortedDeck.map {$0.symbol}
assert(resortedDeck == originalSortedDeck, "Deck sorts back correctly")
resortedDeckSymbols
