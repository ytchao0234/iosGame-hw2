//
//  MenuBar.swift
//  Wordle
//
//  Created by FanRende on 2022/4/15.
//

import SwiftUI

struct MenuBar: View {
    func buttonLabel(imageName: String) -> some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .foregroundColor(Color("plainColor"))
    }
    
    @State private var showSheet: Bool = false
    @State private var type: TYPE = .direction
    
    enum TYPE {
        case direction, summary, setting
    }
    func sheetContent(_ type: TYPE) -> some View {
        switch(type) {
        case .direction:
            return buttonLabel(imageName: "questionmark.circle")
        case .summary:
            return buttonLabel(imageName: "chart.bar")
        case .setting:
            return buttonLabel(imageName: "gearshape")
        }
    }

    var body: some View {
        HStack {
            Button {
                type = .direction
                showSheet.toggle()
            } label: {
                buttonLabel(imageName: "questionmark.circle")
            }

            Spacer()

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
        .frame(height: 20)
        .padding([.top, .horizontal], 10)
        .sheet(isPresented: $showSheet) { [type] in
            sheetContent(type)
        }
    }
}

struct MenuBar_Previews: PreviewProvider {
    static var previews: some View {
        MenuBar()
    }
}
