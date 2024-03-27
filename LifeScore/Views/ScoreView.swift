//
//  ScoreView.swift
//  LifeScore
//
//  Created by Roman Yefimets on 3/20/24.
//

import SwiftUI
import SwiftData
import Charts

struct ScoreView: View {
    @Query(sort: [SortDescriptor(\LifeEvent.timestamp)]) private var events: [LifeEvent]
    @State private var filteredEvents: [LifeEvent] = []
    @State private var selectedRange: String = "ALL"
    @State private var slope: Double = 0.0
    @State private var totalScore: Double = 0.0
    
    func calcTotalScore() {
        self.totalScore = filteredEvents.reduce(0) { $0 + $1.score }
    }
    
    func linearRegression() {
        if filteredEvents.count > 0 {
            let sumX = filteredEvents.indices.reduce(0) { $0 + Double($1) }
            let sumY = filteredEvents.reduce(0) { $0 + $1.score }
            let sumXY = zip(filteredEvents.indices, filteredEvents).reduce(0) { $0 + Double($1.0) * $1.1.score }
            let sumXSquare = filteredEvents.indices.reduce(0) { $0 + Double($1) * Double($1) }
            let n = Double(filteredEvents.count)
            
            let slope = (n * sumXY - sumX * sumY) / (n * sumXSquare - sumX * sumX)
            //let intercept = (sumY - slope * sumX) / n
            self.slope = slope
            print(self.slope)
        }
    }
    
    var body: some View {
        VStack {
              Text("\(totalScore, specifier: "%.1f")")
                .font(.system(size: 100))
                .fontWeight(.bold)
                //.opacity(0.5)
                .foregroundColor(totalScore < 0 ? .red : .green)
                .padding()
            Chart(filteredEvents, id: \.timestamp) {dataPoint in
                let cumulativeScore = events.prefix(while: { $0.timestamp <= dataPoint.timestamp })
                    .reduce(0) { $0 + $1.score }
                LineMark(
                    x: .value("Day", dataPoint.timestamp),
                    y: .value("Views", cumulativeScore)
                )
                .foregroundStyle(totalScore < 0 ? Color.red: Color.green)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {value in
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by:1)) {value in
                }
            }
            .animation(.easeInOut(duration:0.6))
            HStack(spacing: 30) {
                ForEach(["1D", "1W", "1M", "YTD", "ALL"], id: \.self) { option in
                    Button(action: {
                        selectedRange = option
                    }) {
                        Text(option)
                            .padding(10)
                            .foregroundColor(selectedRange == option ? .white : .black)
                            .background(selectedRange == option ? (totalScore >= 0 ? Color.green : Color.red) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.bottom, 40)
            .onChange(of: selectedRange, initial: true) {preEvent, newEvent in
                let currentDate = Date()
                let calendar = Calendar.current
                let lastWeek = calendar.date(byAdding: .day, value: -7, to: currentDate)!
                let lastMonth = calendar.date(byAdding: .day, value: -30, to: currentDate)!

                switch selectedRange {
                case "ALL":
                    filteredEvents = events
                case "YTD":
                    filteredEvents = events.filter { $0.timestamp.isInThisYear }
                case "1M":
                    filteredEvents = events.filter { $0.timestamp >= lastMonth }
                case "1W":
                    filteredEvents = events.filter { $0.timestamp >= lastWeek }
                case "1D":
                    filteredEvents = events.filter { $0.timestamp.isInToday }
                default:
                    break // Handle any additional cases or do nothing for unknown cases
                }
                calcTotalScore()
                //linearRegression()
            }
          }

    }
}

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

#Preview {
    MainView()
        .modelContainer(for: LifeEvent.self, inMemory: true)

}
