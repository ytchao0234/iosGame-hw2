//
//  ResultView.swift
//  Wordle
//
//  Created by FanRende on 2022/6/13.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var game: GameViewModel
    @State private var showSheet: Bool = false
    
    func wordEmoji(_ word: Word, previous: String = "") -> String {
        var result: String = previous + ((previous.count > 0) ? "\n" : "")

        for (idx, letter) in word.content.enumerated() {
            switch(letter.judge) {
            case .CORRECT:
                result += "🟩"
            case .WRONG:
                result += "🟨"
            case .FAILED:
                result += "⬜️"
            default:
                result += "⬜️"
            }
        }
        return result
    }
    
    var result: String {
        var res: String = ""

        for idx in 0..<game.property[game.thisLength].thisTurn {
            res = wordEmoji(game.property[game.thisLength].wordList[idx], previous: res)
        }
        
        return res
    }

    var body: some View {
        VStack {
            Text(game.property[game.thisLength].judgement == .WIN ? "Bingo!" : "Failed...")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("answer: \(game.property[game.thisLength].answer.source)")
                .font(.caption)
                .padding(.bottom)
            Text(result)
                .font(.title2)
                .padding()
                .background(Color.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Button {
                self.showSheet = true
            } label: {
                Label("SHARE", systemImage: "square.and.arrow.up")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .sheet(isPresented: $showSheet) {
                ShareView(result: result, judgement: game.property[game.thisLength].judgement == .WIN, answer: game.property[game.thisLength].answer.source)
            }
            .padding()
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(game: GameViewModel())
    }
}
