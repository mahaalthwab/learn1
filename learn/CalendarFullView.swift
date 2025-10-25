//
//  CalendarFullView.swift
//  learn
//
//  Created by maha althwab on 26/04/1447 AH.
//

import SwiftUI

struct FullCalendarView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var activityVM: ActivityViewModel
    
    @State private var currentDate = Date()
    
    // للألوان المخصصة
    let learnedColor = Color(red: 162/255, green: 73/255, blue: 33/255)
    let freezedColor = Color(red: 54/255, green: 124/255, blue: 135/255)
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // 🔹 العنوان والرجوع
                HStack {
                    Text("All activities")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 6)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // 🔹 التقويم التفاعلي الطويل
                ScrollView {
                    VStack(spacing: 40) {
                        ForEach(0..<6) { i in
                            let date = Calendar.current.date(byAdding: .month, value: -i, to: Date())!
                            MonthView(date: date, learnedColor: learnedColor, freezedColor: freezedColor)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MonthView: View {
    let date: Date
    let learnedColor: Color
    let freezedColor: Color
    @EnvironmentObject var activityVM: ActivityViewModel
    
    var body: some View {
        let monthName = monthFormatter.string(from: date)
        let year = yearFormatter.string(from: date)
        let days = makeDays(for: date)
        
        VStack(spacing: 10) {
            // 🔸 عنوان الشهر
            Text("\(monthName) \(year)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // 🔸 اختصارات الأيام
            HStack(spacing: 12) {
                ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 🔸 شبكة الأيام
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(days, id: \.self) { day in
                    if day == 0 {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 38, height: 38)
                    } else {
                        ZStack {
                            Circle()
                                .fill(colorFor(day: day, in: date))
                                .frame(width: 38, height: 38)
                            
                            Text("\(day)")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    // MARK: - Logic
    func makeDays(for date: Date) -> [Int] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDay)
        
        var days: [Int] = Array(repeating: 0, count: weekday - 1)
        days += range.map { $0 }
        return days
    }
    
    // تلوين اليوم حسب الحالة المخزّنة بالتاريخ الكامل
    func colorFor(day: Int, in monthDate: Date) -> Color {
        var comps = Calendar.current.dateComponents([.year, .month], from: monthDate)
        comps.day = day
        guard let fullDate = Calendar.current.date(from: comps) else {
            return Color.gray.opacity(0.2)
        }
        return activityVM.color(for: fullDate)
    }
    
    // MARK: - Formatters
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }
    
    private var yearFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f
    }
}

#Preview {
    FullCalendarView()
        .environmentObject(ActivityViewModel())
}
