//
//  FormatterService.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/10/24.
//

import Foundation


final class FormatterService {
    
    static func formatDate(date: Date) -> String {
        let dateFormatter = Date.FormatStyle().day().month().year()
        return date.formatted(dateFormatter)
    }
    
    static func formatTimeInterval(seconds: TimeInterval) -> String {
        // Calculate years, months, days, hours, minutes, and seconds
        let minutes = Int(seconds / 60)
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30  // Assuming 30 days per month
        let years = months / 12
        
        let remainingMonths = months % 12
        let remainingDays = days % 30
        let remainingHours = hours % 24
        let remainingMinutes = minutes % 60
        let remainingSeconds = Int(seconds) % 60
        
        // Create the formatted string
        var formattedTime = ""
        if years > 0 {
            formattedTime += "\(years)y "
        }
        if remainingMonths > 0 {
            formattedTime += "\(remainingMonths)mo "
        }
        if remainingDays > 0 {
            formattedTime += "\(remainingDays)d "
        }
        if remainingHours > 0 {
            formattedTime += String(format: "%02d:", remainingHours)
        }
        formattedTime += String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        
        return formattedTime
    }
}
