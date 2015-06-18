//
//  StatusMode.swift
//  SDK
//
//  Created by Duane Homick on 2015-05-26.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The status digits are the left most digits on the timer.  The mode determines what is displayed in those digits while the timer is running.
public enum StatusMode : Int {

    /// Nothing is displayed
    case None = 0,
    /// The interval number is displayed
    Interval = 1,
    /// The repetition number is displayed
    Repetition = 2,
    /// A custom value that is set via setCustomStatus is used
    Custom = 3
    
}
