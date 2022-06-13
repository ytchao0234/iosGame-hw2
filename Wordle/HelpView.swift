//
//  HelpView.swift
//  Wordle
//
//  Created by FanRende on 2022/6/11.
//

import SwiftUI

struct HelpView: View {
    @ObservedObject var game: GameViewModel
    @Binding var show: Bool
    
    var answerLength: String {
        switch(game.setting.answerLength) {
        case 3:
            return "three"
        case 4:
            return "four"
        case 5:
            return "five"
        default:
            return "none"
        }
    }
    
    var word1 = Word("MOUSE")
    var word2 = Word("CAMEL")
    var word3 = Word("SHEEP")
    
    init(game: GameViewModel, show: Binding<Bool>) {
        self._game = ObservedObject(initialValue: game)
        self._show = Binding(projectedValue: show)
        word1.content[0].judge = .CORRECT
        word2.content[1].judge = .WRONG
        word3.content[3].judge = .FAILED
    }

    var body: some View {
        VStack {
            Button {
                self.show = false
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .padding(.top)
            }
            Spacer()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading){
                    Group {
                        Text("How to Play")
                            .font(.title)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

                        Group {
                            Text("Guess the ") + Text("WORDLE").fontWeight(.bold) + Text(" in six tries.")
                            Text("Each guess must be a valid \(answerLength)-letter word. Hit the 'paper plane' button to submit.")
                            Text("You can change the word length for each guess from the settings page.")
                            Text("And you can also change the tile color of the result from there.")
                            Text("After each guess, the color of the tiles will change to show how close your guess was to the word.")
                        }

                        Rectangle()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                            .foregroundColor(.secondary)
                        
                        Group {
                            Text("Example")
                                .font(.title3)
                                .fontWeight(.bold)

                            WordView(word: .constant(word1), letterSize: 25)
                            Group {
                                Text("The letter ") + Text("\(String(word1.content[0].content))").fontWeight(.bold) +
                                Text(" is in the word and in the correct spot.")
                            }
                            .font(.caption)

                            WordView(word: .constant(word2), letterSize: 25)
                            Group {
                                Text("The letter ") + Text("\(String(word2.content[1].content))").fontWeight(.bold) +
                                Text(" is in the word but in the wrong spot.")
                            }
                            .font(.caption)

                            WordView(word: .constant(word3), letterSize: 25)
                            Group {
                                Text("The letter ") + Text("\(String(word3.content[3].content))").fontWeight(.bold) +
                                Text(" is not in the word in any spot.")
                            }
                            .font(.caption)
                        }
                        
                        Rectangle()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                            .foregroundColor(.secondary)
                        
                        Text("A new WORDLE will be available each minute!")
                            .fontWeight(.bold)
                    }
                    .padding(5)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(game: GameViewModel(), show: .constant(true))
    }
}
