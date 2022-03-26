//
//  Word.swift
//  Wordle
//
//  Created by FanRende on 2022/3/26.
//

import SwiftUI

struct Word: Identifiable {
    let id = UUID()
    var content: Array<Letter> = [Letter]()
    
    init(_ content: String) {
        for letter in Array(content) {
            self.content.append(Letter(letter))
        }
    }
}

extension Word {
    static func getEmptyWord(length: Int) -> Word {
        let emptyWord: String = Array(repeating: " ", count: length).joined()
        return Word(emptyWord)
    }
}

struct WordView: View {
    var word: Word

    var body: some View {
        HStack {
            ForEach(word.content) { letter in
                LetterView(letter: letter, size: 30)
            }
        }
    }
}

struct WordView_Previews: PreviewProvider {
    static var previews: some View {
        WordView(word: Word("ABCDE"))
    }
}
