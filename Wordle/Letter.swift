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
    
    static func ==(lhs: Letter, rhs: Letter) -> Bool {
        return lhs.content == rhs.content
    }
}

extension Letter {
    enum JUDGE {
        case NONE, FAILED, WRONG, CORRECT
    }

    static var colorList: Array<Color> = [.clear, .gray, .yellow, .green]
}

struct LetterView: View {
    let letter: Letter
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
    static var previews: some View {
        LetterView(letter: Letter("A"), size: 30)
    }
}
