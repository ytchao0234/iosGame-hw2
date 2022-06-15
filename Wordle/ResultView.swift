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
    @State private var isCopyed: Bool = false
    @AppStorage("result3") var result3: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    @AppStorage("result4") var result4: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    @AppStorage("result5") var result5: String = String("0\n0\n0\n0\n0\n0\n0\n0")
    
    func wordEmoji(_ word: Word, previous: String = "") -> String {
        var result: String = previous + ((previous.count > 0) ? "\n" : "")

        for letter in word.content {
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
            
            HStack {
                let text = "\(game.property[game.thisLength].judgement == .WIN ? "Bingo!" : "Failed...")\nanswer: \(game.property[game.thisLength].answer.source)\n\n\(result)"
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
                    ShareView(text: text)
                }
                Button {
                    UIPasteboard.general.string = text
                    self.isCopyed = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isCopyed = false
                    }
                } label: {
                    ZStack(alignment: .trailing) {
                        Label("COPY", systemImage: "doc.on.doc")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        if self.isCopyed {
                            Image(systemName: "checkmark.circle")
                                .offset(x: 25)
                                .transition(.offset(x: -15).combined(with: .opacity))
                        }
                    }
                    .animation(.easeOut(duration: 0.5), value: self.isCopyed)
                }
            }
            .padding()
        }
        .onAppear {
            var res = ""
            
            for idx in Array(result.split(separator: "\n")).indices {
                res += (res.count > 0 ? "\n" : "") + game.property[game.thisLength].wordList[idx].source
            }
            
            res = result + " " + res + " " +
                  game.property[game.thisLength].answer.source + " " +
                  (game.property[game.thisLength].judgement == .WIN ? "WIN" : "LOSE")
            
            switch(game.thisLength) {
            case 0:
                self.result3 = res + " " + game.property[0].statistics
            case 1:
                self.result4 = res + " " + game.property[1].statistics
            case 2:
                self.result5 = res + " " + game.property[2].statistics
            default:
                break
            }
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(game: GameViewModel())
    }
}
