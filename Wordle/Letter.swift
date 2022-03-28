//
//  Letter.swift
//  Wordle
//
//  Created by FanRende on 2022/3/26.
//

import SwiftUI

struct Letter: Identifiable, Equatable {
    var id = UUID()
    var content: Character = " "
    var judge: JUDGE = .NONE

    init(_ content: Character, judge: JUDGE = .NONE) {
        self.content = content
        self.judge = judge
    }

    func getColor() -> Color {
        switch(self.judge) {
        case .NONE:
            return Letter.colorList[0]
        case .FAILED:
            return Letter.colorList[1]
        case .WRONG:
            return Letter.colorList[2]
        case .CORRECT:
            return Letter.colorList[3]
        }
    }
}

extension Letter {
    enum JUDGE: Int {
        case NONE = 0, FAILED = 1, WRONG = 2, CORRECT = 3
    }

    static var colorList: Array<Color> = [.clear, .gray, .yellow, .green]
}

struct LetterView: View {
    @Binding var letter: Letter
    let size: CGFloat

    var body: some View {
        Text(String(letter.content))
            .font(.title)
            .frame(width: size, height: size)
            .padding(10)
            .background(letter.getColor())
            .overlay(Rectangle().stroke(Color("plainColor"), lineWidth: 3))
    }
}

struct LetterView_Previews: PreviewProvider {
    @State static var letter = Letter("A")

    static var previews: some View {
        LetterView(letter: $letter, size: 30)
    }
}
