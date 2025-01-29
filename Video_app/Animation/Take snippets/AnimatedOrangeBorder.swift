//
//  AnimatedOrangeBorder.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//

import SwiftUI
struct AnimatedOrangeBorder: View {
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .trim(from: 0, to: progress)
            .stroke(Color("orange1"), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .onAppear {
                withAnimation(.linear(duration: 2)) {
                    progress = 1
                }
            }
    }
}
