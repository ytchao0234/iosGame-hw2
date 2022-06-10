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
    
    init(answer: String = "", answerLength: Int = 5, guessTimes: Int = 6) {
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
            MenuBar()

            Text("Wordle")
                .font(.custom("Snell Roundhand", size: 60))
                .fontWeight(.heavy)
            Text("guess an animal")
            
            Spacer()

            ForEach($game.property.wordList) { $word in
                WordView(word: $word)
            }

            Spacer()

            KeyboardView(game: game)
                .padding(.bottom)
                .disabled(game.property.gameOver)
        }
        .background(
            Image("background_eng")
                .resizable()
                .scaledToFill()
                .clipped()
                .ignoresSafeArea()
        )
        .alert(game.property.judgement == .WIN ? "Bingo!" : "answer:\n\(game.property.answer.source)", isPresented: $game.property.gameOver) {
            Button("OK") {
                game.restart()
            }
        }

    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

class GameViewModel: ObservableObject {
    @Published var property: Game = Game()
    @Published var keyboard: Keyboard = Keyboard()
//    let dataSource = ["animal3", "animal4", "animal5"]
    
    init() {
        setAnswer()
    }
    
    func restart() {
        let current = property
        property = Game(answer: current.answer.source)
        keyboard = Keyboard()
    }
    
    func setAnswer() {
        var answer: String = ""

        if let asset = NSDataAsset(name: "animal" + "\(property.answerLength)"),
            let content = String(data: asset.data, encoding: .utf8) {
            answer = String(content.split(separator: "\n").randomElement()!)
        }
        self.property = Game(answer: answer.uppercased())
    }
    
    func setLetter(_ letter: Character) {
        if property.thisLetter == property.answerLength {
            return
        }

        property.wordList[property.thisTurn].setLetter(property.thisLetter, value: letter)
        property.thisLetter += 1
    }
    
    func deleteLetter() {
        if property.thisLetter <= 0 {
            return
        }

        property.thisLetter -= 1
        property.wordList[property.thisTurn].setLetter(property.thisLetter, value: " ")
    }
    
    func judge() {
        if property.thisLetter < property.answerLength {
            return
        }
        
        var correctCount = 0
        
        for idx in property.wordList[property.thisTurn].content.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.5) {
                self.property.wordList[self.property.thisTurn].content[idx].angle = 89

                let guessLetter = self.property.wordList[self.property.thisTurn].content[idx]
                let answerLetter = self.property.answer.content[idx]

                if guessLetter.content == answerLetter.content {
                    self.property.wordList[self.property.thisTurn].setJudge(idx, value: .CORRECT)
                    correctCount += 1
                }
                else if self.property.answer.contains(guessLetter) {
                    self.property.wordList[self.property.thisTurn].setJudge(idx, value: .WRONG)
                }
                else {
                    self.property.wordList[self.property.thisTurn].setJudge(idx, value: .FAILED)
                }
                
                if idx > 0 {
                    self.property.wordList[self.property.thisTurn].content[idx-1].angle = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(property.wordList[property.thisTurn].content.count) * 0.5) {
            self.property.wordList[self.property.thisTurn].content[self.property.wordList[self.property.thisTurn].content.count-1].angle = 0
        }
        
        keyboard.updating(src: property.wordList[property.thisTurn].content)
        
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
