//
//  Game.swift
//  Wordle
//
//  Created by FanRende on 2022/3/27.
//

import SwiftUI

struct Game {
    var answer = Word()
    var wordList: Array<Word> = [Word]()
    
    var thisLetter: Int = 0
    var thisTurn: Int = 0
    var gameOver: Bool = false
    var judgement: JUDGE = .NONE
    
    init(answerLength: Int = 4) {
        self.answer = Word(self.getAnswer(answerLength: answerLength))

        for _ in 0 ..< Game.guessLimit {
            self.wordList.append(Word.getEmptyWord(length: answerLength))
        }
    }
    
    func getAnswer(answerLength: Int) -> String {
        var answer: String = ""

        if let asset = NSDataAsset(name: "animal" + "\(answerLength)"),
            let content = String(data: asset.data, encoding: .utf8) {
            let wordList = content.split(separator: "\n")
            answer = String(wordList.randomElement()!)
            
            print("---- word list ---- (\(answer)) ----\n")
            for (idx, _word) in wordList.enumerated() {
                print(idx, _word)
            }
            print("\n--------")
        }

        return answer.uppercased()
    }
}

extension Game {
    static let guessLimit: Int = 6
    enum JUDGE {
        case NONE, WIN, LOSE
    }
}

struct GameView: View {
    @StateObject var game = GameViewModel()

    var body: some View {
        VStack {
            MenuBar(game: game)

            Text("Wordle")
                .font(.custom("Snell Roundhand", size: 60))
                .fontWeight(.heavy)
            Text("guess an animal")
            
            Spacer()

            ForEach($game.property[game.thisLength].wordList) { $word in
                WordView(word: $word, letterSize: 30)
            }

            Spacer()

            KeyboardView(game: game)
                .padding(.bottom)
                .disabled(game.property[game.thisLength].gameOver)
        }
        .background(
            Image("background_eng")
                .resizable()
                .scaledToFill()
                .clipped()
                .ignoresSafeArea()
        )
        .alert(game.property[game.thisLength].judgement == .WIN ? "Bingo!" : "answer:\n\(game.property[game.thisLength].answer.source)", isPresented: $game.property[game.thisLength].gameOver) {
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
    @Published var property: Array<Game> = [Game]()
    @Published var keyboard: Array<Keyboard> = [Keyboard]()
    @Published var setting: Setting = Setting()
    @Published var thisLength: Int = 0
    
    init() {
        self.thisLength = self.setting.answerLength - Setting.minimumLength

        for length in Setting.wordLength {
            self.property.append(Game(answerLength: length))
            self.keyboard.append(Keyboard())
        }
    }
    
    func restart() {
        property[thisLength] = Game()
        keyboard[thisLength] = Keyboard()
    }
    
    func setLetter(_ letter: Character) {
        if property[thisLength].thisLetter == setting.answerLength {
            return
        }

        property[thisLength].wordList[property[thisLength].thisTurn].setLetter(property[thisLength].thisLetter, value: letter)
        property[thisLength].thisLetter += 1
    }
    
    func deleteLetter() {
        if property[thisLength].thisLetter <= 0 {
            return
        }

        property[thisLength].thisLetter -= 1
        property[thisLength].wordList[property[thisLength].thisTurn].setLetter(property[thisLength].thisLetter, value: " ")
    }
    
    func judge() {
        if property[thisLength].thisLetter < self.setting.answerLength {
            return
        }
        
        var correctCount = 0
        
        for idx in property[thisLength].wordList[property[thisLength].thisTurn].content.indices {
            property[thisLength].wordList[property[thisLength].thisTurn].content[idx].angle = 180

            let guessLetter = property[thisLength].wordList[property[thisLength].thisTurn].content[idx]
            let answerLetter = property[thisLength].answer.content[idx]

            if guessLetter.content == answerLetter.content {
                property[thisLength].wordList[property[thisLength].thisTurn].setJudge(idx, value: .CORRECT)
                correctCount += 1
            }
            else if property[thisLength].answer.contains(guessLetter) {
                property[thisLength].wordList[property[thisLength].thisTurn].setJudge(idx, value: .WRONG)
            }
            else {
                property[thisLength].wordList[property[thisLength].thisTurn].setJudge(idx, value: .FAILED)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for idx in self.property[self.thisLength].wordList[self.property[self.thisLength].thisTurn].content.indices {
                self.property[self.thisLength].wordList[self.property[self.thisLength].thisTurn].content[idx].angle = 0
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.setting.answerLength) * 0.7) {
            self.keyboard[self.thisLength].updating(src: self.property[self.thisLength].wordList[self.property[self.thisLength].thisTurn].content)
            self.property[self.thisLength].thisLetter = 0
            self.property[self.thisLength].thisTurn += 1

            if correctCount == self.setting.answerLength {
                self.property[self.thisLength].gameOver = true
                self.property[self.thisLength].judgement = .WIN
            }
            else if self.property[self.thisLength].thisTurn >= Game.guessLimit {
                self.property[self.thisLength].gameOver = true
                self.property[self.thisLength].judgement = .LOSE
            }
        }
    }
}
