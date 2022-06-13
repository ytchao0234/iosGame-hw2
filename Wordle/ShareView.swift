//
//  ShareView.swift
//  Wordle
//
//  Created by FanRende on 2022/6/13.
//

import UIKit
import SwiftUI
import LinkPresentation

struct ShareView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    let result: String
    let judgement: Bool
    let answer: String

    var text: String {
        "\(judgement ? "Bingo!" : "Failed...")\nanswer: \(answer)\n\n\(result)"
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareView_Previews: PreviewProvider {
    @State static var isSharePresented: Bool = false

    static var previews: some View {
        Button("Share app") {
            self.isSharePresented = true
        }
        .sheet(isPresented: $isSharePresented, onDismiss: {
            print("Dismiss")
        }, content: {
            ShareView(result: "", judgement: true, answer: "")
        })
    }
}
