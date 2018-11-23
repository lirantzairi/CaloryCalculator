//
//  Date.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/16/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import Foundation

extension Date
{
    func isSmallerThanOrEqualToInTime(to date: Date) -> Bool
    {
        let calendar = Calendar.current
        let components2 = calendar.dateComponents([.hour, .minute, .second], from: date)
        let date2 = calendar.date(bySettingHour: components2.hour!, minute: components2.minute!, second: components2.second!, of: self)!
        
        return self <= date2
    }
}
