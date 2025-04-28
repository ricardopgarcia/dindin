//
//  InvestmentDataPoint.swift
//  dindin
//
//  Created by Ricardo Garcia on 27/04/25.
//

import Foundation

struct InvestmentDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

extension InvestmentDataPoint {
    static let mockOneMonth: [InvestmentDataPoint] = [
        InvestmentDataPoint(date: Date().addingTimeInterval(-25*24*60*60), value: 10000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-20*24*60*60), value: 10100),
        InvestmentDataPoint(date: Date().addingTimeInterval(-15*24*60*60), value: 10200),
        InvestmentDataPoint(date: Date().addingTimeInterval(-10*24*60*60), value: 10300),
        InvestmentDataPoint(date: Date().addingTimeInterval(-5*24*60*60), value: 10400),
        InvestmentDataPoint(date: Date(), value: 10500)
    ]
    
    static let mockSixMonths: [InvestmentDataPoint] = [
        InvestmentDataPoint(date: Date().addingTimeInterval(-150*24*60*60), value: 9000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-120*24*60*60), value: 9500),
        InvestmentDataPoint(date: Date().addingTimeInterval(-90*24*60*60), value: 9700),
        InvestmentDataPoint(date: Date().addingTimeInterval(-60*24*60*60), value: 10000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-30*24*60*60), value: 10300),
        InvestmentDataPoint(date: Date(), value: 10500)
    ]
    
    static let mockOneYear: [InvestmentDataPoint] = [
        InvestmentDataPoint(date: Date().addingTimeInterval(-360*24*60*60), value: 8500),
        InvestmentDataPoint(date: Date().addingTimeInterval(-270*24*60*60), value: 9000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-180*24*60*60), value: 9500),
        InvestmentDataPoint(date: Date().addingTimeInterval(-90*24*60*60), value: 10000),
        InvestmentDataPoint(date: Date(), value: 10500)
    ]
    
    static let mockFiveYears: [InvestmentDataPoint] = [
        InvestmentDataPoint(date: Date().addingTimeInterval(-5*360*24*60*60), value: 6000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-4*360*24*60*60), value: 7000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-3*360*24*60*60), value: 8000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-2*360*24*60*60), value: 9000),
        InvestmentDataPoint(date: Date().addingTimeInterval(-1*360*24*60*60), value: 10000),
        InvestmentDataPoint(date: Date(), value: 10500)
    ]
}
