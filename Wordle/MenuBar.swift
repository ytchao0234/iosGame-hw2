//
//  MenuBar.swift
//  Wordle
//
//  Created by FanRende on 2022/4/15.
//

import SwiftUI

struct MenuBar: View {
    @ObservedObject var game: GameViewModel
    @AppStorage("time3") var time3: Double = 0
    @AppStorage("time4") var time4: Double = 0
    @AppStorage("time5") var time5: Double = 0
    
    func buttonLabel(imageName: String) -> some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .foregroundColor(Color("plainColor"))
    }
    
    @State private var showSheet: Bool = false
    @State private var type: TYPE = .help
    
    enum TYPE {
        case help, summary, setting
    }
    func sheetContent(_ type: TYPE) -> some View {
        switch(type) {
        case .help:
            return AnyView(HelpView(game: game, show: $showSheet))
        case .summary:
            return AnyView(SummaryView(game: game, show: $showSheet))
        case .setting:
            return AnyView(SettingView(game: game, show: $showSheet))
        }
    }
    
    func gameOver(idx: Int) {
        print("game.countDown: \(idx)")
        game.countDown(idx: idx)

        if game.property[idx].countDownTime == game.property[idx].timeLimit {
            self.type = .summary
            self.showSheet = true

            switch(idx) {
            case 0:
                self.time3 = Date.now.timeIntervalSince1970
            case 1:
                self.time4 = Date.now.timeIntervalSince1970
            case 2:
                self.time5 = Date.now.timeIntervalSince1970
            default:
                break
            }
        }
    }
    
    func stateChange(_ newValue: Bool, idx: Int) {
        if newValue && !showSheet {
            self.gameOver(idx: idx)
        }
        else if !newValue && game.thisLength == idx && self.type == .summary && self.showSheet {
            self.showSheet = false
        }
    }

    var body: some View {
        HStack {
            Button {
                type = .help
                showSheet.toggle()
            } label: {
                buttonLabel(imageName: "questionmark.circle.fill")
            }

            Spacer()

            Group {
                Button {
                    type = .summary
                    showSheet.toggle()
                } label: {
                    buttonLabel(imageName: "chart.bar.fill")
                }
                Button {
                    type = .setting
                    showSheet.toggle()
                } label: {
                    buttonLabel(imageName: "gearshape.fill")
                }
            }
            .padding(.trailing, 5)
        }
        .frame(height: 20)
        .padding([.top, .horizontal], 10)
        .sheet(isPresented: $showSheet) { [type] in
            sheetContent(type)
        }
        .onChange(of: game.property[0].gameOver) { newValue in
            stateChange(newValue, idx: 0)
        }
        .onChange(of: game.property[1].gameOver) { newValue in
            stateChange(newValue, idx: 1)
        }
        .onChange(of: game.property[2].gameOver) { newValue in
            stateChange(newValue, idx: 2)
        }
    }
}

struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBar(game: GameViewModel())
    }
}
