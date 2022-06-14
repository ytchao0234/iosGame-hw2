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
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    if game.property[game.thisLength].gameOver {
                        ResultView(game: game)

                        DividerView()
                            .padding(5)
                    }
                    Text("Statistics")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    StatisticsView(game: game)
                }
            }
            .padding([.top, .horizontal])
            Spacer()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(game: GameViewModel(), show: .constant(true))
    }
}


struct StatisticsView: View {
    @ObservedObject var game: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            let total = game.property[game.thisLength].playedTimes

            ScoreRow(title: "Played ",
                     score: total,
                     ratio: 1)

            ForEach(game.property[game.thisLength].score.indices) { idx in
                let score = game.property[game.thisLength].score[idx]

                ScoreRow(title: idx + 1 < 7 ? (idx + 1 > 1 ? "\(idx+1) tries" : "1 try  ")  : "Failed ",
                         score: score,
                         ratio: total > 0 ? Double(score) / Double(total) : 1)
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding()
    }
}

struct ScoreRow: View {
    let title: String
    let score: Int
    let ratio: Double

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.body, design: .monospaced))
            GeometryReader { geometry in
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: geometry.size.width * ((ratio > 0) ? ratio : 0.01), height: geometry.size.height)
            }
            Spacer()
            Text("\(score)")
                .font(.system(.body, design: .monospaced))
        }
    }
}
