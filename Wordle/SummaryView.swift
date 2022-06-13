//
//  SummaryView.swift
//  Wordle
//
//  Created by FanRende on 2022/6/11.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var game: GameViewModel
    @Binding var show: Bool

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
            Text("SummaryView")
            Spacer()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(game: GameViewModel(), show: .constant(true))
    }
}
