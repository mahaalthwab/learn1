//
//  ActivityViewModel.swift .swift
//  learn
//
//  Created by maha althwab on 29/04/1447 AH.
//
import Foundation
import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    // 🧠 المتغيرات الي تتغير مع الوقت
    @Published var learnedDays = 0
    @Published var freezedDays = 0
    @Published var streakCount = 0
    @Published var maxFreezes = 2
    @Published var circleOffset: CGFloat = 30
    @Published var buttonSpacing: CGFloat = 30
    @Published var borderOpacity: Double = 0.3
    @Published var boxHeight: CGFloat = 300
    @Published var isLearnedToday = false
    @Published var isFreezedToday = false
    @Published var learnedDaysSet: Set<Int> = []
    @Published var freezedDaysSet: Set<Int> = []
    @Published var isLearnedActive = false
    @Published var isFreezedActive = false
    
    
    
    

    // 🗓️ متغيرات التقويم
    @Published var selectedMonth = Calendar.current.component(.month, from: Date())
    @Published var selectedYear = Calendar.current.component(.year, from: Date())
    @Published var selectedDay = 24
    @Published var startDay = 20
    @Published var endDay = 26
    @Published var showPicker = false

    private let lastActionDateKey = "lastActionDate"

    // ✅ تخزين حالات الأيام حسب التاريخ الكامل
    enum DayState: String, Codable {
        case none
        case learned
        case freezed
    }

    @Published private(set) var dayStates: [String: DayState] = [:] // key = "yyyy-MM-dd"

    private let dayStatesKey = "dayStates.v1"

    init() {
        loadSavedData()
        loadDayStates()
        checkForNewDay()
    }

    // 🟠 المستخدم ضغط زر "تعلم"
    func logAsLearned() {
        guard !isLearnedToday && !isFreezedToday else { return }

        isLearnedToday = true
        learnedDays += 1
        streakCount += 1

        // ✅ نحدد اليوم الحالي
        let day = Calendar.current.component(.day, from: Date())
        learnedDaysSet.insert(day)

        // ✅ سجل بالتاريخ الكامل
        setState(for: Date(), .learned)

        saveActionDate()
        saveData()
        saveDayStates()
    }

    // 🔵 المستخدم ضغط زر "تجميد"
    func logAsFreezed() {
        guard !isLearnedToday && !isFreezedToday else { return }

        let day = Calendar.current.component(.day, from: Date())

        if freezedDays < maxFreezes {
            isFreezedToday = true
            freezedDays += 1

            // ✅ نضيف اليوم إلى مجموعة الأيام المجمّدة
            freezedDaysSet.insert(day)

            // ✅ سجل بالتاريخ الكامل
            setState(for: Date(), .freezed)
        } else {
            // ❗ تجاوز الحد → تصفير الستريك
            streakCount = 0
        }

        saveActionDate()
        saveData()
        saveDayStates()
    }

    // 🕛 حفظ تاريخ آخر مرة ضغط فيها المستخدم
    private func saveActionDate() {
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: lastActionDateKey)
    }

    // 💾 حفظ بيانات المستخدم
    private func saveData() {
        UserDefaults.standard.set(isLearnedToday, forKey: "isLearnedToday")
        UserDefaults.standard.set(isFreezedToday, forKey: "isFreezedToday")
        UserDefaults.standard.set(learnedDays, forKey: "learnedDays")
        UserDefaults.standard.set(freezedDays, forKey: "freezedDays")
        UserDefaults.standard.set(streakCount, forKey: "streakCount")

        let learnedArray = Array(learnedDaysSet)
        let freezedArray = Array(freezedDaysSet)
        UserDefaults.standard.set(learnedArray, forKey: "learnedDaysSet")
        UserDefaults.standard.set(freezedArray, forKey: "freezedDaysSet")
    }

    // 🔁 تحميل البيانات المحفوظة
    private func loadSavedData() {
        isLearnedToday = UserDefaults.standard.bool(forKey: "isLearnedToday")
        isFreezedToday = UserDefaults.standard.bool(forKey: "isFreezedToday")
        learnedDays = UserDefaults.standard.integer(forKey: "learnedDays")
        freezedDays = UserDefaults.standard.integer(forKey: "freezedDays")
        streakCount = UserDefaults.standard.integer(forKey: "streakCount")

        if let learnedArray = UserDefaults.standard.array(forKey: "learnedDaysSet") as? [Int] {
            learnedDaysSet = Set(learnedArray)
        }
        if let freezedArray = UserDefaults.standard.array(forKey: "freezedDaysSet") as? [Int] {
            freezedDaysSet = Set(freezedArray)
        }
    }

    // 🔄 إعادة التهيئة عند اختيار مادة جديدة
    func resetProgress() {
        learnedDays = 0
        freezedDays = 0
        streakCount = 0
        isLearnedToday = false
        isFreezedToday = false
        learnedDaysSet.removeAll()
        freezedDaysSet.removeAll()
        dayStates.removeAll()
        saveData()
        saveDayStates()
    }

    // 🌙 يتحقق إذا بدأ يوم جديد (بعد ١٢ صباحًا)
    private func checkForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastActionDateKey) as? Date ?? .distantPast

        if today > lastDate {
            // بدأ يوم جديد → إعادة تعيين الأزرار
            isLearnedToday = false
            isFreezedToday = false
        } else {
            // نفس اليوم → نترك الحالة كما هي (زر غير قابل للضغط)
            isLearnedToday = UserDefaults.standard.bool(forKey: "isLearnedToday")
            isFreezedToday = UserDefaults.standard.bool(forKey: "isFreezedToday")
        }
    }

    // MARK: - Day states storage (by full date)
    private func key(for date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Calendar.current.startOfDay(for: date))
    }

    private func loadDayStates() {
        if let data = UserDefaults.standard.data(forKey: dayStatesKey),
           let decoded = try? JSONDecoder().decode([String: DayState].self, from: data) {
            dayStates = decoded
        }
    }

    private func saveDayStates() {
        if let data = try? JSONEncoder().encode(dayStates) {
            UserDefaults.standard.set(data, forKey: dayStatesKey)
        }
    }

    private func setState(for date: Date, _ state: DayState) {
        dayStates[key(for: date)] = state
    }

    func state(for date: Date) -> DayState {
        dayStates[key(for: date)] ?? .none
    }

    func color(for date: Date) -> Color {
        switch state(for: date) {
        case .learned:
            return Color(red: 162/255, green: 73/255, blue: 33/255) // برتقالي
        case .freezed:
            return Color(red: 54/255, green: 124/255, blue: 135/255) // أزرق
        case .none:
            return Color.gray.opacity(0.2)
        }
    }
}
