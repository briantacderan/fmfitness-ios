//
//  SchedulerModel.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/28/22.
//

import Foundation

final class SchedulerModel: ObservableObject, Identifiable {
    
    static var shared = SchedulerModel()
    
    let dayFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let finalFormatter = DateFormatter()
    let weekArray = ["THIS WEEK", "NEXT WEEK", "WEEK AFTER"]
    let timeArray = ["8:30AM", "11:00AM", "1:30PM", "4:00PM", "6:30PM", "9:00PM"]
    let dayBetweenDates: TimeInterval = 3600 * 24 // one day
    
    @Published var startingDate = Date() // now
    @Published var endDate = Date(timeIntervalSinceNow: 3600 * 24 * 7) // one week from now
    @Published var currentDate = Date()
    
    @Published var dayArray = ["0", "1", "2", "3", "4", "5", "6"]
    @Published var dates: [Date] = intervalDates(from: Date(), to: Date(timeIntervalSinceNow: 3600 * 24 * 7), with: 3600 * 24)
    @Published var trainingDay = Date()
    @Published var times = dayTimeSlots(Date())
    @Published var trainingTime = Date()
    @Published var timeFinal = ""
    
    init() {
        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "M"
        finalFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d h:mm a")
        dayArray = ["TODAY", "TOMORROW"]
        for i in 2...6 {
            dayArray.append("\(monthFormatter.string(from: Date(timeIntervalSinceNow: 3600 * 24 * Double(i))))/\(dayFormatter.string(from: Date(timeIntervalSinceNow: 3600 * 24 * Double(i))))")
        }
        startingDate = Date()
        endDate = Date(timeIntervalSinceNow: 3600 * 24 * 6)
        dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
        times = dayTimeSlots(startingDate)
        trainingDay = startingDate
        trainingTime = times[0]
        timeFinal = finalFormatter.string(from: trainingTime)
    }
    
    func resetScheduler() {
        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "M"
        finalFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d h:mm a")
        dayArray = ["TODAY", "TOMORROW"]
        for i in 2...6 {
            dayArray.append("\(monthFormatter.string(from: Date(timeIntervalSinceNow: 3600 * 24 * Double(i))))/\(dayFormatter.string(from: Date(timeIntervalSinceNow: 3600 * 24 * Double(i))))")
        }
        startingDate = Date()
        endDate = Date(timeIntervalSinceNow: 3600 * 24 * 6)
        dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
        times = dayTimeSlots(startingDate)
        trainingDay = startingDate
        trainingTime = times[0]
        timeFinal = finalFormatter.string(from: trainingTime)
        weekIndex = 0
        dayIndex = 0
        timeIndex = 0
    }

    @Published var weekIndex = 0 {
        didSet {
            switch weekIndex {
            case 0:
                dayArray = ["TODAY", "TOMORROW"]
                for i in 2...6 {
                    currentDate = Date(timeIntervalSinceNow: 3600 * 24 * Double(i))
                    dayArray.append("\(monthFormatter.string(from: currentDate))/\(dayFormatter.string(from: currentDate))")
                }
                startingDate = Date()
                endDate = Date(timeIntervalSinceNow: 3600 * 24 * 6)
                dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
            case 1:
                dayArray = []
                for i in 0...6 {
                    currentDate = Date(timeIntervalSinceNow: 3600 * 24 * Double(7+i))
                    dayArray.append("\(monthFormatter.string(from: currentDate))/\(dayFormatter.string(from: currentDate))")
                }
                startingDate = Date(timeIntervalSinceNow: 3600 * 24 * 7)
                endDate = Date(timeIntervalSinceNow: 3600 * 24 * 13)
                dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
            case 2:
                dayArray = []
                for i in 0...6 {
                    currentDate = Date(timeIntervalSinceNow: 3600 * 24 * Double(14+i))
                    dayArray.append("\(monthFormatter.string(from: currentDate))/\(dayFormatter.string(from: currentDate))")
                }
                startingDate = Date(timeIntervalSinceNow: 3600 * 24 * 14)
                endDate = Date(timeIntervalSinceNow: 3600 * 24 * 20)
                dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
            default:
                dayArray = ["TODAY", "TOMORROW"]
                for i in 2...6 {
                    currentDate = Date(timeIntervalSinceNow: 3600 * 24 * Double(i))
                    dayArray.append("\(monthFormatter.string(from: currentDate))/\(dayFormatter.string(from: currentDate))")
                }
                startingDate = Date()
                endDate = Date(timeIntervalSinceNow: 3600 * 24 * 7)
                dates = intervalDates(from: startingDate, to: endDate, with: dayBetweenDates)
            }
        }
    }
    
    @Published var dayIndex = 0 {
        didSet{
            switch dayIndex {
            case 0:
                trainingDay = startingDate
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 1:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (1 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 2:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (2 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 3:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (3 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 4:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (4 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 5:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (5 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 6:
                trainingDay = Date(timeIntervalSinceNow: 3600 * 24 * (6 + (Double(weekIndex)*7)))
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            default:
                trainingDay = startingDate
                times = dayTimeSlots(trainingDay)
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            }
        }
    }
    
    @Published var timeIndex = 0 {
        didSet{
            switch timeIndex {
            case 0:
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 1:
                trainingTime = times[1]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 2:
                trainingTime = times[2]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 3:
                trainingTime = times[3]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 4:
                trainingTime = times[4]
                timeFinal = finalFormatter.string(from: trainingTime)
            case 5:
                trainingTime = times[5]
                timeFinal = finalFormatter.string(from: trainingTime)
            default:
                trainingTime = times[0]
                timeFinal = finalFormatter.string(from: trainingTime)
            }
        }
    }
}

func intervalDates(from startingDate:Date, to endDate:Date, with interval:TimeInterval) -> [Date] {
    guard interval > 0 else { return [] }

    var dates:[Date] = []
    var currentDate = startingDate

    while currentDate <= endDate {
        currentDate = currentDate.addingTimeInterval(interval)
        dates.append(currentDate)
    }

    return dates
}

func dayTimeSlots(_ trainingDay: Date) -> [Date] {
    
    let calendar = Calendar.current
    let startTime: DateComponents
    let endTime: DateComponents
    let month: Int
    let day: Int
    let year: Int
    let timeBetweenAppts: TimeInterval = 3600 * 2.5 // two and a half hours
    let dayFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let yearFormatter = DateFormatter()
    
    dayFormatter.dateFormat = "d"
    monthFormatter.dateFormat = "M"
    yearFormatter.dateFormat = "yyyy"
    
    month = Int(monthFormatter.string(from: trainingDay)) ?? 1
    day = Int(dayFormatter.string(from: trainingDay)) ?? 1
    year = Int(yearFormatter.string(from: trainingDay)) ?? 2022
    startTime = DateComponents(calendar: calendar,
                               year: year,
                               month: month,
                               day: day,
                               hour: 6)
    endTime = DateComponents(calendar: calendar,
                             year: year,
                             month: month,
                             day: day,
                             hour: 21)
    return intervalDates(from: calendar.date(from: startTime)!,
                         to: calendar.date(from: endTime)!,
                         with: timeBetweenAppts)
}
