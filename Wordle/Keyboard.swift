//
//  Keyboard.swift
//  Wordle
//
//  Created by FanRende on 2022/3/27.
//

import SwiftUI

struct Keyboard {
    var English = [Array("QWERTYUIOP"), Array("ASDFGHJKL"), Array("ZXCVBNM")]
    var maxCount: Int
    
    init() {
        self.maxCount = self.English[0].count
        
        for list in self.English {
            self.maxCount = (list.count > self.maxCount) ? list.count : self.maxCount
        }
    }
}

struct KeyboardView: View {
    var keyboard = Keyboard()
    @ObservedObject var game: GameViewModel

    var body: some View {
        VStack {
            ForEach(keyboard.English, id: \.self) { list in
                let isLast = list == keyboard.English.last
                KeyRow(game: game, content: list, isLast: isLast)
                    .padding(.bottom, 5)
            }
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    @State static var letter = Letter(" ")

    static var previews: some View {
        KeyboardView(game: GameViewModel())
    }
}

struct KeyRow: View {
    @ObservedObject var game: GameViewModel
    let content: Array<Character>
    let isLast: Bool

    var body: some View {
        HStack {
            if isLast {
                Button {
                    game.judge()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .modifier(KeyModifier())
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.blue, lineWidth: 2))
                }
            }

            ForEach(content, id: \.self) { letter in
                Button {
                    game.setLetter(letter)
                } label: {
                    Text(String(letter))
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .modifier(KeyModifier())
                }
            }

            if isLast {
                Button {
                    game.deleteLetter()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .modifier(KeyModifier())
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.blue, lineWidth: 2))
                }
            }
        }
    }
}

struct KeyModifier: ViewModifier {
    func body(content: Content) -> some View {
        let size = UIScreen.main.bounds.width * 0.8 / 10

        content
            .foregroundColor(Color("plainColor"))
            .frame(width: size, height: size)
            .background(.secondary)
            .cornerRadius(5)
    }
}
