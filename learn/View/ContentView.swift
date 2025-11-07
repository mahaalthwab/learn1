//
//  ContentView.swift
//  learn
//
//  Created by maha althwab on 25/04/1447 AH.
//
import SwiftUI

struct ContentView: View {
    @State private var learningTopic: String = "" // يبدأ فاضي لأن Swift صارت placeholder
    @State private var timeFrame: TimeFrame = .week
    @State private var navigateToActivity = false
    @StateObject private var activityVM = ActivityViewModel() // موديل مشترك لكل الشاشات

    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    logoSection
                    greetingSection
                    topicSection
                    timeframeSection
                    Spacer()

                    // زر Start learning
                    Button("Start learning") {
                        // ✅ يضبط عدد أيام التجميد حسب اختيار البداية
                        activityVM.configureFreezes(for: timeFrame.rawValue)
                        // ✅ يفعّل التنقّل
                        navigateToActivity = true
                    }
                    .frame(width: 182, height: 48)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.25))
                            .glassEffect(
                                .clear
                                    .tint(Color(hex: "#FF9230").opacity(0.15))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color(hex: "#FF9230").opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: Color(hex: "#FF9230").opacity(0.35), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 40)
                }
            }
            // ✅ مكان التنقّل الصحيح: على مستوى الـ NavigationStack (خارج الـ VStack)
            .navigationDestination(isPresented: $navigateToActivity) {
                ActivityView(topic: learningTopic)
                    .environmentObject(activityVM) // تمرير نفس الموديل
            }
        }
        // ❌ لا ننشئ ViewModel جديد هنا حتى ما تصير نسختين
        // .environmentObject(ActivityViewModel())
    }

    private var logoSection: some View {
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
            // TextField مع placeholder رمادي "Swift"
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
                            // خلفية بنفس ستايل زر الزجاج (بدون Capsule)
                            .background(
                                Rectangle()
                                    .fill(Color.black.opacity(0.25))
                                    .glassEffect(
                                        .clear
                                            .tint(
                                                (timeFrame == frame
                                                 ? Color(hex: "#FF9230")
                                                 : Color.gray
                                                ).opacity(0.15)
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                            )
                            // إطار بدون Capsule
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        timeFrame == frame
                                        ? Color(hex: "#FF9230").opacity(0.6)
                                        : Color.gray.opacity(0.4),
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

#Preview {
    ContentView()
}

