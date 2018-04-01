//
//  DateComponentsFormatter+Cooldown.swift
//  Cooldown
//
//  Created by Matt Jones on 3/31/18.
//  Copyright © 2018 Matt Jones. All rights reserved.
//

import Foundation

public extension DateComponentsFormatter {
    
    public static let cooldownFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute, .second]
        f.maximumUnitCount = 2
        return f
    }()
    
}
