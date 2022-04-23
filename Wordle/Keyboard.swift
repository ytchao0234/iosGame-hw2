//
//  Keyboard.swift
//  Wordle
//
//  Created by FanRende on 2022/3/27.
//

import SwiftUI

struct Keyboard {
    var content: Array<Array<Letter>>
    var maxCount: Int
    
    init(_ type: TYPE = .ENGLISH) {
        switch(type) {
        case .ENGLISH:
            self.content = Keyboard.english
        }

        self.maxCount = self.content[0].count

        for list in self.content {
            self.maxCount = (list.count > self.maxCount) ? list.count : self.maxCount
        }
    }
    
    mutating func updating(src: Array<Letter>) {
        for letter in src {
            for (idx, list) in content.enumerated() {
                if let i = list.firstIndex(where: { $0.content == letter.content }),
                   list[i].judge.rawValue < letter.judge.rawValue {
                    content[idx][i] = letter
                }
            }
        }
    }
}

extension Keyboard {
    enum TYPE {
        case ENGLISH
    }
    static let english = [Word("QWERTYUIOP").content, Word("ASDFGHJKL").content, Word("ZXCVBNM").content]
}

struct KeyboardView: View {
    @ObservedObject var game: GameViewModel

    var body: some View {
        VStack {
            ForEach(game.keyboard.content.indices) { rowIdx in
                let isLast = rowIdx == game.keyboard.content.count - 1
                KeyRow(game: game, rowIdx: rowIdx, isLast: isLast)
                    .padding(.bottom, 5)
            }
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(game: GameViewModel())
    }
}

struct KeyRow: View {
    @ObservedObject var game: GameViewModel
    let rowIdx: Int
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

            ForEach(game.keyboard.content[rowIdx]) { letter in
                Button {
                    game.setLetter(letter.content)
                } label: {
                    Text(String(letter.content))
                        .font(.system(size: 20, weight: .regular, design: .monospaced))
                        .modifier(KeyModifier(letter: letter))
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
    var letter: Letter = Letter(" ")

    var color: Color {
        if letter.judge != .NONE {
            return letter.getColor()
        }
        else {
            return Color.blue.opacity(0.5)
        }
    }

    func body(content: Content) -> some View {
        let size = UIScreen.main.bounds.width * 0.8 / 10

        content
            .foregroundColor(Color("plainColor"))
            .frame(width: size, height: size)
            .background(color)
            .cornerRadius(5)
    }
}
