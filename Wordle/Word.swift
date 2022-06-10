//
//  Word.swift
//  Wordle
//
//  Created by FanRende on 2022/3/26.
//

import SwiftUI

struct Word: Identifiable {
    let id = UUID()
    var source: String = String()
    var content: Array<Letter> = [Letter]()
    var length: Int = 0
    
    init() {}
    
    init(_ source: String) {
        self.source = source

        for letter in Array(source) {
            self.content.append(Letter(letter))
        }
        
        self.length = self.content.count
    }
    
    mutating func setLetter(_ index: Int, value: Character) {
        if index >= 0, index < content.count {
            content[index].content = value
        }
    }
    
    mutating func setJudge(_ index: Int, value: Letter.JUDGE) {
        if index >= 0, index < content.count {
            content[index].judge = value
        }
    }
    
    func contains(_ value: Letter) -> Bool {
        return content.firstIndex(where: {$0.content == value.content}) != nil
    }
}

extension Word {
    static func getEmptyWord(length: Int) -> Word {
        let emptyWord: String = Array(repeating: " ", count: length).joined()
        return Word(emptyWord)
    }
}

struct WordView: View {
    @Binding var word: Word

    var body: some View {
        HStack {
            ForEach($word.content) { $letter in
                LetterView(letter: $letter, size: 30)
            }
        }
    }
}

struct WordView_Previews: PreviewProvider {
    @State static var word = Word("ABCDE")

    static var previews: some View {
        WordView(word: $word)
    }
}
