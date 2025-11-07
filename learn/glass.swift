//
//  glass.swift
//  learn
//
//  Created by maha althwab on 27/04/1447 AH.
//

// Created by Rana on 23/04/1447 AH
import SwiftUI

struct GlassButtonView: View {
    var body: some View {
        ZStack {
            
            Button("Start learning") {
                // action
            }
            .frame(width: 182, height: 48)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .glassEffect(.clear
                .tint(Color(hex: "#FF9230")
            .opacity(15)))
        }}
}
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }}
#Preview {
    GlassButtonView()
}
