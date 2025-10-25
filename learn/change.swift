//
//  change.swift
//  learn
//
//  Created by maha althwab on 27/04/1447 AH.
//
import SwiftUI

struct LearningGoalView: View {
    @State private var learningTopic: String = ""
    @State private var timeFrame: TimeFrame = .month
    @State private var navigateToActivity = false
    @State private var showConfirmation = false // ✅ حالة ظهور شعار التأكيد
    @StateObject private var viewModel = ActivityViewModel() // ✅ نربط نفس المودل

    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 30) {
                    
                    // العنوان وحقل الإدخال
                    VStack(alignment: .leading, spacing: 10) {
                        Text("I want to learn")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                        
                        ZStack(alignment: .leading) {
                            if learningTopic.isEmpty {
                                Text("Swift")
                                    .foregroundColor(.gray)
                                    .opacity(0.6)
                            }
                            TextField("", text: $learningTopic)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                                .padding(.vertical, 8)
                                .accentColor(.orange)
                        }
                        
                        Rectangle()
                            .fill(Color(white: 0.2))
                            .frame(height: 1)
                    }
                    
                    // أزرار المدة
                    VStack(alignment: .leading, spacing: 14) {
                        Text("I want to learn it in a")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                        
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
                                        .background(
                                            Capsule()
                                                .fill(timeFrame == frame ? Color("Orange") : Color.gray.opacity(0.25))
                                                .glassEffect(.regular.tint(
                                                    timeFrame == frame ? Color.orange.opacity(0.3) : Color.black.opacity(0.4)
                                                ))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    timeFrame == frame
                                                    ? Color("Orange").opacity(0.6)
                                                    : Color.gray.opacity(0.4),
                                                    lineWidth: 1.5
                                                )
                                        )
                                        .shadow(color: timeFrame == frame ? Color.orange.opacity(0.5) : Color.black.opacity(0.4),
                                                radius: 10, x: 0, y: 5)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                // ✅ التنقل
                NavigationLink(destination: ActivityView(topic: learningTopic), isActive: $navigateToActivity) {
                    EmptyView()
                }
                
                // ✅ مربع التأكيد
                if showConfirmation {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Text("Update Learning goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("If you update now, your streak will start over.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    withAnimation {
                                        showConfirmation = false
                                    }
                                }) {
                                    Text("Dismiss")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(14)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        // ✅ تصفير كل القيم قبل الانتقال
                                        viewModel.resetProgress()
                                        showConfirmation = false
                                        navigateToActivity = true
                                    }
                                }) {
                                    Text("Update")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding()
                        .background(Color(red: 25/255, green: 25/255, blue: 25/255))
                        .cornerRadius(24)
                        .padding(.horizontal, 40)
                        .shadow(radius: 20)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showConfirmation)
                }
            }
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
            
            // ✅ زر التشيك
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            showConfirmation = true
                        }
                    } label: {
                        Image("check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    LearningGoalView()
}










