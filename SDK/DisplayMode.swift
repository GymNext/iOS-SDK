//
//  DisplayMode.swift
//  SDK
//
//  Created by Duane Homick on 2015-05-27.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The mode of display for the timer
public enum DisplayMode : Int {

    /// The chronological time
    case Clock = 0,
    /// The elapsed or remaining time of the current schedule
    Timer = 1,
    /// A customizable message
    Message = 2
}
