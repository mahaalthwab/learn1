//
//  glass.swift
//  learn
//
//  Created by maha althwab on 27/04/1447 AH.
//

// Created by Rana on 23/04/1447 AH
import SwiftUI

struct GlassButtonView: View {
    @State private var learningTopic: String = ""
    @State private var timeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // الشعار
                LogoView()
                
                // القسم تحت الشعار: التحية + حقل الإدخال
                greetingSection
                topicSection
                timeframeSection
                
                Spacer()
                
                Button("Start learning") {
                    // action
                }
                .frame(width: 182, height: 48)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .glassEffect(.clear
                    .tint(Color(hex: "#FF9230").opacity(15)))
                .padding(.bottom, 40) // مسافة بسيطة من أسفل الشاشة
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Sections copied from ContentView
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hello Learner")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(.white)
            Text("This app will help you learn everyday!")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
    
    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("I want to learn")
                .foregroundColor(.white)
                .font(.system(size: 20))
            
            ZStack(alignment: .leading) {
                if learningTopic.isEmpty {
                    Text("Swift")
                        .foregroundColor(.gray)
                        .opacity(0.6)
                }
                
                TextField("", text: $learningTopic)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .padding(.vertical, 10)
                    .accentColor(.orange)
            }
            
            Rectangle()
                .fill(Color(white: 0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, 24)
    }
    
    private var timeframeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("I want to learn it in a")
                .foregroundColor(.white)
                .font(.system(size: 20))
            
            HStack(spacing: 16) {
                ForEach(TimeFrame.allCases) { frame in
                    Button(action: {
                        withAnimation(.spring()) {
                            timeFrame = frame
                        }
                    }) {
                        Text(frame.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(timeFrame == frame ? .white : .gray)
                            .frame(minWidth: 90, minHeight: 44)
                            .padding(.horizontal, 6)
                            .background(
                                // نفس ستايل زر Start للزر المختار
                                Rectangle()
                                    .fill(Color.black.opacity(0.25))
                                    .glassEffect(
                                        .clear.tint(
                                            (timeFrame == frame
                                             ? Color(hex: "#FF9230")
                                             : Color.gray
                                            ).opacity(0.15)
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        timeFrame == frame
                                        ? Color(hex: "#FF9230").opacity(0.6)
                                        : Color.gray.opacity(0.35),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: timeFrame == frame
                                ? Color(hex: "#FF9230").opacity(0.35)
                                : .clear,
                                radius: 10, x: 0, y: 5
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// View قابلة لإعادة الاستخدام للشعار
struct LogoView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.25))
                .frame(width: 140, height: 140)
                .shadow(color: .orange.opacity(0.6), radius: 30, x: 0, y: 10)
                .glassEffect(.clear)
            
            ZStack {
                Image(systemName: "flame.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.orange)
            }
            .shadow(color: .black.opacity(0.7), radius: 18, x: 0, y: 6)
        }
    }
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
    }
}


#Preview {
    GlassButtonView()
}
