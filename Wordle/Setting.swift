//
//  SettingView.swift
//  Wordle
//
//  Created by FanRende on 2022/6/11.
//

import SwiftUI

struct Setting {
    var answerLength: Int = 4
    var correctColor: Color = Letter.colorList[3]
    var wrongColor: Color = Letter.colorList[2]
    var failedColor: Color = Letter.colorList[1]
}

extension Setting {
    static let minimumLength = 3
    static let wordLength = Setting.minimumLength...5
}

struct SettingView: View {
    @ObservedObject var game: GameViewModel
    @Binding var show: Bool
    
    func colorPicker(idx: Int, title: String, color: Binding<Color>) -> some View {
        ColorPicker(selection: color) {
            Text(title)
        }
        .onChange(of: color.wrappedValue) { newValue in
            Letter.colorList[idx] = newValue
        }
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

            Form {
                Section {
                    Group {
                        colorPicker(idx: 3, title: "Correct Color", color: $game.setting.correctColor)
                        colorPicker(idx: 2, title: "Wrong Color", color: $game.setting.wrongColor)
                        colorPicker(idx: 1, title: "Incorrect Color", color: $game.setting.failedColor)
                    }
                    .padding(.vertical, 10)
                } header: {
                    Text("Letter Color")
                }

                Picker(selection: $game.setting.answerLength) {
                    ForEach(Array(Setting.wordLength), id: \.self) { i in
                        Text("\(i) letters").tag(i)
                    }
                } label: {
                    Text("Answer Length")
                }
                .pickerStyle(.inline)
                .padding(.vertical, 10)
                .onChange(of: game.setting.answerLength) { newValue in
                    game.thisLength = newValue - Setting.minimumLength
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(game: GameViewModel(), show: .constant(true))
    }
}
