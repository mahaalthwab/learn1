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
    // ✅ اسم المادة مع حفظ تلقائي
    @Published var learningTopic: String {
        didSet { UserDefaults.standard.set(learningTopic, forKey: "learningTopic") }
    }

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
    @Published var goalCompleted = false

    // 🗓️ متغيرات التقويم
    @Published var selectedMonth = Calendar.current.component(.month, from: Date())
    @Published var selectedYear  = Calendar.current.component(.year,  from: Date())
    @Published var selectedDay   = 24
    @Published var startDay      = 20
    @Published var endDay        = 26
    @Published var showPicker    = false

    private let lastActionDateKey   = "lastActionDate"

    // ✅ تخزين حالات الأيام حسب التاريخ الكامل
    enum DayState: String, Codable {
        case none, learned, freezed
    }
    @Published private(set) var dayStates: [String: DayState] = [:] // key = "yyyy-MM-dd"
    private let dayStatesKey = "dayStates.v1"

    // 🟧 مدة الهدف المعتمدة على الاختيار + تاريخ بداية الهدف
    @Published var goalStartDate: Date? {
        didSet {
            if let d = goalStartDate {
                UserDefaults.standard.set(d, forKey: goalStartDateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: goalStartDateKey)
            }
        }
    }
    @Published var goalDurationDays: Int = 7 { // افتراضي أسبوع
        didSet { UserDefaults.standard.set(goalDurationDays, forKey: goalDurationDaysKey) }
    }
    private let goalStartDateKey   = "goalStartDate"
    private let goalDurationDaysKey = "goalDurationDays"

    // MARK: - Init
    init() {
        // ⬇️ اقرأ اسم المادة المحفوظ
        self.learningTopic = UserDefaults.standard.string(forKey: "learningTopic") ?? ""

        loadSavedData()
        loadDayStates()
        // ⬇️ اقرأ إعدادات مدة الهدف
        if let d = UserDefaults.standard.object(forKey: goalStartDateKey) as? Date {
            self.goalStartDate = d
        }
        let gd = UserDefaults.standard.integer(forKey: goalDurationDaysKey)
        self.goalDurationDays = gd == 0 ? 7 : gd

        checkForNewDay()
        checkGoalPeriod()
    }

    // 👇 دالة مريحة لتغيير المادة (مع خيار إعادة التقدّم)
    func updateTopic(_ newTopic: String, resetProgressIfChanged: Bool = true) {
        let trimmed = newTopic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != learningTopic else { return }
        learningTopic = trimmed
        if resetProgressIfChanged { resetProgress() }
    }

    // MARK: - Public API to mark today and persist by full date
    func markLearnedToday(date: Date = Date()) {
        setState(for: date, .learned)
        saveDayStates()
    }

    func markFreezedToday(date: Date = Date()) {
        setState(for: date, .freezed)
        saveDayStates()
    }

    // 🟠 المستخدم ضغط زر "تعلم"
    func logAsLearned() {
        guard !isLearnedToday && !isFreezedToday else { return }

        isLearnedToday = true
        learnedDays += 1
        streakCount += 1

        let day = Calendar.current.component(.day, from: Date())
        learnedDaysSet.insert(day)

        setState(for: Date(), .learned)
        saveDayStates()

        // ✅ ما عاد نعتمد على streak؛ نتحقق من نهاية الفترة
        saveActionDate()
        saveData()
        checkGoalPeriod()
    }

    // 🔵 المستخدم ضغط زر "تجميد"
    func logAsFreezed() {
        guard !isLearnedToday && !isFreezedToday else { return }

        let day = Calendar.current.component(.day, from: Date())

        if freezedDays < maxFreezes {
            isFreezedToday = true
            freezedDays += 1
            freezedDaysSet.insert(day)

            setState(for: Date(), .freezed)
            saveDayStates()
        }

        // ✅ ما عاد نعتمد على streak؛ نتحقق من نهاية الفترة
        saveActionDate()
        saveData()
        checkGoalPeriod()
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
        UserDefaults.standard.set(maxFreezes, forKey: "maxFreezes")
        // learningTopic محفوظ تلقائي في didSet
        // goalStartDate & goalDurationDays محفوظين في didSet أيضًا
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

        let savedMax = UserDefaults.standard.integer(forKey: "maxFreezes")
        if savedMax > 0 { maxFreezes = savedMax }
    }

    // 🔄 إعادة التهيئة عند اختيار مادة جديدة
    func resetProgress() {
        learnedDays = 0
        freezedDays = 0
        streakCount = 0
        isLearnedToday = false
        isFreezedToday = false
        goalCompleted = false
        learnedDaysSet.removeAll()
        freezedDaysSet.removeAll()
        dayStates.removeAll()
        goalStartDate = nil
        // ما نغيّر goalDurationDays هنا؛ راح يتضبط عند startGoal()
        saveData()
        saveDayStates()
    }

    // MARK: - Initial freeze quota by timeframe
    func configureFreezes(for initialChoiceRawValue: String) {
        switch initialChoiceRawValue {
        case "Week":  self.maxFreezes = 2
        case "Month": self.maxFreezes = 8
        case "Year":  self.maxFreezes = 96
        default:      break
        }
    }

    // ✅ بدء الهدف حسب المدة المختارة
    func startGoal(for timeframeRaw: String) {
        let today = Calendar.current.startOfDay(for: Date())
        self.goalStartDate = today

        switch timeframeRaw {
        case "Week":  self.goalDurationDays = 7
        case "Month": self.goalDurationDays = 30
        case "Year":  self.goalDurationDays = 365
        default:      self.goalDurationDays = 7
        }

        self.goalCompleted = false
        configureFreezes(for: timeframeRaw)
        saveData()
        checkGoalPeriod()
    }

    // 🌙 يتحقق إذا بدأ يوم جديد (بعد ١٢ صباحًا)
    private func checkForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastActionDateKey) as? Date ?? .distantPast

        if today > lastDate {
            isLearnedToday = false
            isFreezedToday = false
        } else {
            isLearnedToday = UserDefaults.standard.bool(forKey: "isLearnedToday")
            isFreezedToday = UserDefaults.standard.bool(forKey: "isFreezedToday")
        }
    }

    // MARK: - Goal period helpers
    private func startOfDay(_ d: Date) -> Date {
        Calendar.current.startOfDay(for: d)
    }

    private func daysSinceStart() -> Int {
        guard let start = goalStartDate else { return 0 }
        let from = startOfDay(start)
        let to   = startOfDay(Date())
        return Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }

    func checkGoalPeriod() {
        guard goalDurationDays > 0, goalStartDate != nil else { return }
        if daysSinceStart() >= goalDurationDays {
            goalCompleted = true
        }
    }

    func remainingDays() -> Int {
        max(0, goalDurationDays - daysSinceStart())
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
        case .learned: return Color(red: 162/255, green: 73/255, blue: 33/255) // برتقالي
        case .freezed: return Color(red: 54/255, green: 124/255, blue: 135/255) // أزرق
        case .none:    return Color.gray.opacity(0.2)
        }
    }
}





 





