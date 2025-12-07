//  actv.swift
//  learn
//
//  Created by maha althwab on 25/04/1447 AH.
import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var viewModel: ActivityViewModel
    @State private var navigateToChange = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                VStack(spacing: 10) {
                    // الأقسام
                    headerSection
                    calendarBox
                    Spacer()
                
                    // 🔘 الزر البرتقالي الكبير
                    if viewModel.goalCompleted {
                        // 🎉 شاشة "Well Done"
                        VStack(spacing: 20) {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                                .padding(.top, 40)
                            
                            Text("Well done!")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Goal completed! Start learning again or set a new learning goal.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.horizontal, 30)
                            
                            Button(action: {
                                // ✅ تصفير كل شيء والانتقال لتحديد هدف جديد
                                withAnimation {
                                    viewModel.resetProgress()
                                }
                                navigateToChange = true
                            }) {
                                Text("Set new learning goal")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(25)
                                    .padding(.horizontal, 60)
                                    .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            
                            Button(action: {
                                // ✅ إعادة تشغيل نفس الهدف بنفس المدة الحالية
                                withAnimation {
                                    let tf: String
                                    switch viewModel.goalDurationDays {
                                    case 7:   tf = "Week"
                                    case 30:  tf = "Month"
                                    case 365: tf = "Year"
                                    default:  tf = "Week"
                                    }
                                    viewModel.resetProgress()
                                    viewModel.startGoal(for: tf)
                                }
                            }) {
                                Text("Set same learning goal and duration")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        .transition(.opacity .combined(with: .scale))
                        .padding(.top, 0)
                    } else {
                        // 🔘 الأزرار الأصلية (البرتقالي والأزرق)
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
                                    viewModel.isFreezedToday ? Color(red: 130/255, green: 200/255, blue: 230/255) :
                                    viewModel.isLearnedToday ? Color(red: 162/255, green: 73/255, blue: 33/255) :
                                    .white
                                )
                            }
                            .frame(width: 220, height: 220)
                            .background(
                                ZStack {
                                    if viewModel.isLearnedToday || viewModel.isFreezedToday {
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
                        .padding(.top, 20)
                    }
                }
                
                // الانتقال إلى صفحة تغيير الهدف
                .navigationDestination(isPresented: $navigateToChange) {
                    LearningGoalView()
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                // ✅ تحقّق عند الفتح إن كانت الفترة انتهت
                viewModel.checkGoalPeriod()
            }
            .navigationBarHidden(true)
        }
    }
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
                        .environmentObject(viewModel)
                ) {
                    Image("cal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(Circle())
                }
                NavigationLink(
                    destination: LearningGoalView()
                        .environmentObject(viewModel)
                ) {
                    Image("sign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var calendarBox: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.clear)
            .frame(height: viewModel.boxHeight)
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
                        // ✅ يقرأ اسم المادة من الموديل مباشرة
                        Text("Learning \(viewModel.learningTopic.isEmpty ? "Swift" : viewModel.learningTopic)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // ✅ عرض الأيام المتبقية
                        let remain = viewModel.remainingDays()
                        Text("Remaining: \(remain) day\(remain == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                    .stroke(Color.gray.opacity(viewModel.borderOpacity), lineWidth: 1)
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
            .background(Color.clear)
            .cornerRadius(10)
        }
    }
    
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
            }
        }
    }
    
    struct CalendarHeader: View {
        @ObservedObject var viewModel: ActivityViewModel
        @Binding var selectedMonth: Int
        @Binding var selectedYear: Int
        @Binding var selectedDay: Int
        @Binding var startDay: Int
        @Binding var endDay: Int
        @Binding var showPicker: Bool
        
        // بداية الأسبوع الحالية حسب تقويم الجهاز
        @State private var currentWeekStart: Date = {
            let cal = Calendar.current
            let today = Date()
            if let start = cal.dateInterval(of: .weekOfYear, for: today)?.start {
                return start
            }
            let wd = cal.component(.weekday, from: today)
            return cal.date(byAdding: .day, value: -(wd - cal.firstWeekday + 7) % 7, to: today) ?? today
        }()
        
        var body: some View {
            VStack(spacing: 8) {
                // 🔹 عنوان الشهر والسنة
                HStack {
                    let headerMonth = Calendar.current.component(.month, from: currentWeekStart)
                    let headerYear = Calendar.current.component(.year, from: currentWeekStart)
                    
                    Text("\(monthName(headerMonth)) \(String(format: "%d", headerYear))")
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
                    ForEach(weekdaySymbols(), id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(width: 36)
                    }
                }
                
                // 🔹 الأيام (دوائر الأسبوع الحالي)
                HStack(spacing: 18) {
                    ForEach(0..<7, id: \.self) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: currentWeekStart)!
                        let dayNumber = Calendar.current.component(.day, from: date)
                        ZStack {
                            Circle()
                                .fill(viewModel.color(for: date))
                                .frame(width: 36, height: 36)
                            
                            Text("\(dayNumber)")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
                            selectedYear = comps.year ?? selectedYear
                            selectedMonth = comps.month ?? selectedMonth
                            selectedDay = comps.day ?? selectedDay
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        
        func weekdaySymbols() -> [String] {
            let cal = Calendar.current
            let symbols = cal.shortWeekdaySymbols.map { $0.uppercased() }
            let start = cal.firstWeekday - 1
            return Array(symbols[start...] + symbols[..<start])
        }
        
        func previousDays() {
            if let newStart = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) {
                withAnimation(.easeInOut) { currentWeekStart = newStart }
            }
        }
        
        func nextDays() {
            if let newStart = Calendar.current.date(byAdding: .day, value: 7, to: currentWeekStart) {
                withAnimation(.easeInOut) { currentWeekStart = newStart }
            }
        }
        
        func monthName(_ month: Int) -> String {
            let formatter = DateFormatter()
            return formatter.monthSymbols[month - 1]
        }
    }
}





