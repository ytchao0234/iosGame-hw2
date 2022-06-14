//
//  Game.swift
//  Wordle
//
//  Created by FanRende on 2022/3/27.
//

import SwiftUI

struct Game {
    var answer: Word
    var wordList: Array<Word> = [Word]()
    
    var thisLetter: Int = 0
    var thisTurn: Int = 0
    var gameOver: Bool = false
    var judgement: JUDGE = .NONE
    var showAlert: Bool = false
    var alertMessage: String = ""

    var timer: Timer? = nil
    var timeUp: Bool = false
    let timeLimit: TimeInterval = 60 * 1
    var countDownTime: TimeInterval = 60 * 1
    var timerLabel = String()
    var formatter = DateFormatter()
    
    var playedTimes: Int = 0
    var score: Array<Int> = Array<Int>(repeating: 0, count: 7)
    var statistics: String {
        String(playedTimes) + "\n" + score.map { String($0) }.joined(separator: "\n")
    }

    init(answerLength: Int = 4, playedTimes: Int = 0, score: Array<Int> = Array<Int>(repeating: 0, count: 7)) {
        self.answer = Word(Game.getAnswer(answerLength: answerLength))
        self.playedTimes = playedTimes
        self.score = score

        for _ in 0 ..< Game.guessLimit {
            self.wordList.append(Word.getEmptyWord(length: answerLength))
        }

        self.formatter.dateFormat = "HH:mm:ss"

        let dateComponent = DateComponents(
            calendar: .current,
            hour: 0, minute: 1, second: 0)
        self.timerLabel =
            self.formatter.string(from: dateComponent.date!)
    }
    
    mutating func setWordList(_ record: String) {
        let temp = record.split(separator: " ")

        if temp.count < 4 {
            return
        }
        
        let colorList = temp[0].split(separator: "\n")
        let letterList = temp[1].split(separator: "\n")
        let answer = temp[2]
        let judgement = temp[3]
        
        self.answer = Word(String(answer))
        self.judgement = (judgement == "WIN") ? .WIN : .LOSE
        self.thisTurn = colorList.count
        
        for idx in colorList.indices {
            let wordColor = Array(colorList[idx])
            let wordLetter = Array(letterList[idx])
            
            for i in wordColor.indices {
                self.wordList[idx].setLetter(i, value: wordLetter[i])
                switch(wordColor[i]) {
                case "🟩":
                    self.wordList[idx].setJudge(i, value: .CORRECT)
                case "🟨":
                    self.wordList[idx].setJudge(i, value: .WRONG)
                case "⬜️":
                    self.wordList[idx].setJudge(i, value: .FAILED)
                default:
                    self.wordList[idx].setJudge(i, value: .NONE)
                }
            }
        }
    }
}

extension Game {
    static let guessLimit: Int = 6
    enum JUDGE {
        case NONE, WIN, LOSE
    }
    
    static func getAnswer(answerLength: Int) -> String {
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

struct GameView: View {
    @StateObject var game = GameViewModel()
    @AppStorage("time3") var time3: Double = 0
    @AppStorage("time4") var time4: Double = 0
    @AppStorage("time5") var time5: Double = 0
    @AppStorage("result3") var result3: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    @AppStorage("result4") var result4: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    @AppStorage("result5") var result5: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    
    func checkRecord(idx: Int) {
        let now = Date.now
        let amountOfNow = now.timeIntervalSince1970
        let adding = game.property[idx].timeLimit
        var remainder: TimeInterval = 0
        var result = String()

        switch(idx) {
        case 0:
            remainder =  self.time3 + adding - amountOfNow
            result = self.result3
        case 1:
            remainder =  self.time4 + adding - amountOfNow
            result = self.result4
        case 2:
            remainder =  self.time5 + adding - amountOfNow
            result = self.result5
        default:
            break
        }

        if let score = result.split(separator: " ").last {
            let temp = score.split(separator: "\n")
            game.property[idx].playedTimes = Int(temp[0]) ?? 0

            temp.enumerated().forEach { (i, amount) in
                if i > 0 {
                    game.property[idx].score[i-1] = Int(temp[i]) ?? 0
                }
            }
        }
        
        if remainder > 0 {
            game.property[idx].countDownTime = round(remainder)

            let dateComponent = DateComponents(
                calendar: .current,
                hour: 0,
                minute: Int(game.property[idx].countDownTime) / 60,
                second: Int(game.property[idx].countDownTime) % 60
            )
            game.property[idx].timerLabel = game.property[idx].formatter.string(from: dateComponent.date!)

            game.property[idx].gameOver = true
            game.property[idx].setWordList(result)
            
            for word in game.property[idx].wordList {
                game.keyboard[idx].updating(src: word.content)
            }
        }
    }

    var body: some View {
        VStack {
            MenuBar(game: game)

            Text("Wordle")
                .font(.custom("Snell Roundhand", size: 60))
                .fontWeight(.heavy)
            if game.property[game.thisLength].gameOver {
                Text("next round -- " + game.property[game.thisLength].timerLabel)
            }
            else {
                Text("guess an animal")
            }

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
        .alert(game.property[game.thisLength].alertMessage, isPresented: $game.property[game.thisLength].showAlert) {
            Button("OK") {}
        }
        .onAppear {
            for i in game.property.indices {
                self.checkRecord(idx: i)
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

    func countDown(idx: Int) {
        self.property[idx].timer?.invalidate()

        property[idx].timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.property[idx].countDownTime > 0 && self.property[idx].gameOver {
                self.property[idx].countDownTime -= 1
                
                let dateComponent = DateComponents(
                    calendar: .current,
                    hour: 0,
                    minute: Int(self.property[idx].countDownTime) / 60,
                    second: Int(self.property[idx].countDownTime) % 60
                )
                self.property[idx].timerLabel = self.property[idx].formatter.string(from: dateComponent.date!)
            }
            else {
                self.property[idx].timer?.invalidate()
                if self.property[idx].countDownTime == 0 {
                    self.restart(idx: idx)
                }
            }
        })
    }
    
    func restart(idx: Int) {
        property[idx] = Game(playedTimes: property[idx].playedTimes, score: property[idx].score)
        keyboard[idx] = Keyboard()
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
        if !property[thisLength].wordList[property[thisLength].thisTurn].isInList() {
            property[thisLength].showAlert = true
            property[thisLength].alertMessage = "Not in Word List"
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
                self.property[self.thisLength].score[self.property[self.thisLength].thisTurn-1] += 1
                self.property[self.thisLength].playedTimes += 1
            }
            else if self.property[self.thisLength].thisTurn >= Game.guessLimit {
                self.property[self.thisLength].gameOver = true
                self.property[self.thisLength].judgement = .LOSE
                self.property[self.thisLength].score[self.property[self.thisLength].score.count-1] += 1
                self.property[self.thisLength].playedTimes += 1
            }
        }
    }
}
