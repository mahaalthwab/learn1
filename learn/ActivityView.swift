//  actv.swift
//  learn
//
//  Created by maha althwab on 25/04/1447 AH.
import SwiftUI
struct ActivityView: View {
    var topic: String = "Swift"
    @StateObject private var viewModel = ActivityViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 10) {
                    // 👇 هنا تنادين الأقسام
                    headerSection
                    calendarBox
                    Spacer()
                    
                    // 🔘 الزر البرتقالي الكبير
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.logAsLearned()
                        }
                    }) {
                        VStack {
                            Text(
                                viewModel.isFreezedToday ? "Day Freezed" :
                                viewModel.isLearnedToday ? "Learned Today" :
                                "Log as\nLearned"
                            )
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .foregroundColor(
                                viewModel.isFreezedToday ? Color(red: 130/255, green: 200/255, blue: 230/255) : // أزرق
                                viewModel.isLearnedToday ? Color(red: 162/255, green: 73/255, blue: 33/255) :  // برتقالي
                                .white
                            )
                        }
                        .frame(width: 220, height: 220)
                        .background(
                            ZStack {
                                if viewModel.isLearnedToday || viewModel.isFreezedToday {
                                    // ✅ تأثير الزجاج بعد الضغط
                                    Circle()
                                        .fill(Color.black.opacity(0.25))
                                        .shadow(
                                            color: viewModel.isLearnedToday
                                                ? .orange.opacity(0.7)
                                                : Color(red: 54/255, green: 124/255, blue: 135/255).opacity(0.7),
                                            radius: 30, x: 0, y: 10
                                        )
                                        .glassEffect(.clear)
                                } else {
                                    // ✅ اللون العادي قبل الضغط
                                    Circle()
                                        .fill(Color(red: 162/255, green: 73/255, blue: 33/255))
                                        .shadow(color: .black.opacity(0.8), radius: 10, x: 0, y: 8)
                                }
                            }
                        )
                        .clipShape(Circle())
                    }
                    .disabled(viewModel.isLearnedToday || viewModel.isFreezedToday)
                    .offset(y: viewModel.circleOffset)




                    
                    Spacer().frame(height: viewModel.buttonSpacing)
                    // 🔵 الزر الأزرق السفلي
                    VStack(spacing: 6) {
                        Button(action: {
                            viewModel.logAsFreezed()
                        }) {
                            Text("Log as Freezed")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (viewModel.freezedDays >= viewModel.maxFreezes || viewModel.isFreezedToday || viewModel.isLearnedToday)
                                    ? Color.gray.opacity(0.5)
                                    : Color(red: 54/255, green: 124/255, blue: 135/255)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 60)
                                .shadow(
                                    color: viewModel.isFreezedToday || viewModel.isLearnedToday ? .clear : Color.cyan.opacity(0.4),
                                    radius: 10, x: 0, y: 5
                                )
                        }
                        .disabled(viewModel.isFreezedToday || viewModel.isLearnedToday)

                        
                        Text("\(viewModel.freezedDays) out of \(viewModel.maxFreezes) Freezes used")
                            .font(.caption)
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 10)
                }
            }
            .navigationBarHidden(true)
        }}
}
// MARK: - Components
extension ActivityView {
    
    private var headerSection: some View {
        HStack {
            Text("Activity")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 16) {
                NavigationLink(
                    destination: FullCalendarView()
                        .environmentObject(viewModel) // ✅ تمرير EnvironmentObject
                ) {
                    Image("cal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(Circle())
                }
                NavigationLink(destination: LearningGoalView()) {
                    Image("sign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(Circle())
                }
            }}
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var calendarBox: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black)
            .frame(height: viewModel.boxHeight) // لو ما عندك boxHeight في الـ ViewModel حطي رقم ثابت 300
            .overlay(
                VStack(spacing: 0) {
                    // ⬆️ رأس التقويم + البيكر
                    VStack(spacing: 12) {
                        CalendarHeader(
                            viewModel: viewModel,
                            selectedMonth: $viewModel.selectedMonth,
                            selectedYear: $viewModel.selectedYear,
                            selectedDay: $viewModel.selectedDay,
                            startDay: $viewModel.startDay,
                            endDay: $viewModel.endDay,
                            showPicker: $viewModel.showPicker
                        )

                        
                        
                        if viewModel.showPicker {
                            MonthYearPickerView(
                                selectedMonth: $viewModel.selectedMonth,
                                selectedYear: $viewModel.selectedYear
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // ⬇️ البطاقات (Learned / Freezed)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Learning \(topic.isEmpty ? "Swift" : topic)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            // 🟠 Learned
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(viewModel.learnedDays)")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("\(viewModel.learnedDays == 1 ? "Day" : "Days") Learned")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 87/255, green: 58/255, blue: 33/255))
                            .clipShape(Capsule())
                            
                            // 🔵 Freezed
                            HStack(spacing: 8) {
                                Image(systemName: "cube.fill")
                                    .foregroundColor(Color(red: 130/255, green: 200/255, blue: 230/255))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(viewModel.freezedDays)")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("\(viewModel.freezedDays == 1 ? "Day" : "Days") Freezed")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 40/255, green: 80/255, blue: 100/255))
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(viewModel.borderOpacity), lineWidth: 1) // لو ما عندك borderOpacity في الـ ViewModel، حطي قيمة ثابتة 0.3
            )
            .padding(.horizontal)
    }
    struct MonthYearPickerView: View {
        @Binding var selectedMonth: Int
        @Binding var selectedYear: Int
        
        let months = (1...12).map { $0 }
        let years = (Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date()) + 10)
        
        var body: some View {
            HStack {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1])
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120)
                .clipped()
                
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)")
                            .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100)
                .clipped()
            }
            .background(Color.black)
            .cornerRadius(10)
        }}
    
    struct CircleButton: View {
        let imageName: String
        var body: some View {
            Button(action: {}) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(Circle())
            }}}
    
    struct CalendarHeader: View {
        @ObservedObject var viewModel: ActivityViewModel
        @Binding var selectedMonth: Int
        @Binding var selectedYear: Int
        @Binding var selectedDay: Int
        @Binding var startDay: Int
        @Binding var endDay: Int
        @Binding var showPicker: Bool
        
        var body: some View {
            VStack(spacing: 8) {
                // 🔹 عنوان الشهر والسنة
                HStack {
                    Text("\(monthName(selectedMonth)) \(String(format: "%d", selectedYear))")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            showPicker.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.orange)
                            .font(.system(size: 16, weight: .bold))
                            .rotationEffect(.degrees(showPicker ? 90 : 0))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: previousDays) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.orange)
                        }
                        Button(action: nextDays) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                // 🔹 أسماء الأيام
                HStack(spacing: 18) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 36)
                    }
                }
                
                // 🔹 الأيام (الدوائر)
                HStack(spacing: 18) {
                    ForEach(startDay...endDay, id: \.self) { day in
                        ZStack {
                            Circle()
                                .fill(colorForDay(day))
                                .frame(width: 36, height: 36)
                            
                            Text("\(day)")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            selectedDay = day
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        
        // 🟠🔵 دالة تحديد لون اليوم
        func colorForDay(_ day: Int) -> Color {
            if viewModel.learnedDaysSet.contains(day) {
                return Color(red: 162/255, green: 73/255, blue: 33/255) // برتقالي
            } else if viewModel.freezedDaysSet.contains(day) {
                return Color(red: 54/255, green: 124/255, blue: 135/255) // أزرق
            } else if day == selectedDay {
                return Color.gray.opacity(0.3)
            } else {
                return Color.gray.opacity(0.15)
            }
        }
        
        // 🗓️ دوال التحكم في التنقل بين الأيام
        func monthName(_ month: Int) -> String {
            let formatter = DateFormatter()
            return formatter.monthSymbols[month - 1]
        }
        
        func previousDays() {
            startDay -= 7
            endDay -= 7
            selectedDay = startDay
        }
        
        func nextDays() {
            startDay += 7
            endDay += 7
            selectedDay = startDay
        }
    }

}
