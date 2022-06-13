//
//  MenuBar.swift
//  Wordle
//
//  Created by FanRende on 2022/4/15.
//

import SwiftUI

struct MenuBar: View {
    @ObservedObject var game: GameViewModel
    
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

    var body: some View {
        HStack {
            Button {
                type = .help
                showSheet.toggle()
            } label: {
                buttonLabel(imageName: "questionmark.circle")
            }

            Spacer()

            Group {
                Button {
                    type = .summary
                    showSheet.toggle()
                } label: {
                    buttonLabel(imageName: "chart.bar")
                }
                Button {
                    type = .setting
                    showSheet.toggle()
                } label: {
                    buttonLabel(imageName: "gearshape")
                }
            }
            .padding(.trailing, 5)
        }
        .frame(height: 20)
        .padding([.top, .horizontal], 10)
        .sheet(isPresented: $showSheet) { [type] in
            sheetContent(type)
        }
    }
}

struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBar(game: GameViewModel())
    }
}
