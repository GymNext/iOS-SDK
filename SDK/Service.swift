//
//  Service.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-06.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// Unique identifier for the Timer Service
public let TIMER_SERVICE_ID = "TimerService"
public let HEART_RATE_SERVICE_ID = "HeartRateService"

public protocol Service {

    var id : String { get }
}
