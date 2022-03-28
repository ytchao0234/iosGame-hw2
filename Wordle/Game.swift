//
//  Game.swift
//  Wordle
//
//  Created by FanRende on 2022/3/27.
//

import SwiftUI

struct Game {
    let answer: Word
    var wordList: Array<Word> = [Word]()
    var answerLength: Int
    var guessTimes: Int
    
    var thisLetter: Int = 0
    var thisTurn: Int = 0
    var gameOver: Bool = false
    var judgement: JUDGE = .NONE
    
    init(answer: String, answerLength: Int, guessTimes: Int) {
        self.answer = Word(answer)
        self.answerLength = answerLength
        self.guessTimes = guessTimes

        for _ in 0 ..< guessTimes {
            self.wordList.append(Word.getEmptyWord(length: answerLength))
        }
    }
}

extension Game {
    enum JUDGE {
        case NONE, WIN, LOSE
    }
}

struct GameView: View {
    @StateObject var game = GameViewModel()

    var body: some View {
        VStack {
            Spacer()

            ForEach($game.property.wordList) { $word in
                WordView(word: $word)
            }

            Spacer()

            KeyboardView(game: game)
                .padding(.bottom)
                .disabled(game.property.gameOver)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

class GameViewModel: ObservableObject {
    @Published var property: Game = Game(answer: "ABCDE", answerLength: 5, guessTimes: 7)
    @Published var keyboard: Keyboard = Keyboard()
    
    func setLetter(_ letter: Character) {
        if property.thisLetter == property.answerLength {
            return
        }

        property.wordList[property.thisTurn].content[property.thisLetter].content = letter
        property.thisLetter += 1
        
        if property.thisLetter > property.answerLength {
            property.thisLetter = property.answerLength
        }
    }
    
    func deleteLetter() {
        if property.thisLetter <= 0 {
            return
        }

        property.wordList[property.thisTurn].content[property.thisLetter - 1].content = " "
        property.thisLetter -= 1
    }
    
    func judge() {
        if property.thisLetter < property.answerLength {
            return
        }
        
        var correctCount = 0

        for idx in property.wordList[property.thisTurn].content.indices {
            let guessLetter = property.wordList[property.thisTurn].content[idx]
            let answerLetter = property.answer.content[idx]

            if guessLetter.content == answerLetter.content {
                property.wordList[property.thisTurn].content[idx].judge = .CORRECT
                correctCount += 1
            }
            else if property.answer.content.firstIndex(where: {$0.content == guessLetter.content}) != nil {
                property.wordList[property.thisTurn].content[idx].judge = .WRONG
            }
            else {
                property.wordList[property.thisTurn].content[idx].judge = .FAILED
            }
        }
        
        for letter in property.wordList[property.thisTurn].content {
            for (idx, list) in keyboard.content.enumerated() {
                if let i = list.firstIndex(where: { $0.content == letter.content }),
                   list[i].judge.rawValue < letter.judge.rawValue {
                    keyboard.content[idx][i] = letter
                }
            }
        }
        
        property.thisLetter = 0
        property.thisTurn += 1

        if correctCount == property.answerLength {
            property.gameOver = true
            property.judgement = .WIN
        }
        else if property.thisTurn >= property.guessTimes {
            property.gameOver = true
            property.judgement = .LOSE
        }
    }
}
