//
//  TimerSchedule.swift
//  SDK
//
//  Created by Duane Homick on 2015-05-26.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The type of the interval
public enum TimerIntervalType : Int {

    /// This interval is work
    case Work = 0,
    
    /// This interval is rest
    Rest = 1
}

/// An interval is made up of a type and duration
public struct TimerInterval {
    
    /// The duration of the interval
    public var duration : Int = 0
    
    /// The type of the interval
    public var intervalType : TimerIntervalType = .Work
    
    
    /// Default constructor
    public init () {
        // empty constructor
    }
    
    /// Fully populated constructor
    ///
    /// :param: duration
    ///     The duration of the interval
    /// :param: intervalType
    ///     The type of the interval
    public init (duration : Int, intervalType : TimerIntervalType) {
        self.duration = duration
        self.intervalType = intervalType
    }
}

/// The schedule for the timer to track.  The schedule is made up of a list of intervals to track in order and convenience variables for repeating intervals or specifying common rest periods.
public struct TimerSchedule {

    /// The intervals that comprise the schedule
    public var intervals : Array<TimerInterval> = []
    
    /// Convenience for a common rest between each interval
    public var restBetweenIntervals :  Int = 0
    
    /// How many times to repeat all the intervals (aka. rounds)
    public var numberOfRepetitions : Int = 1
    
    /// Convenience for a common rest between each repetition of the intervals
    public var restBetweenRepetitions : Int = 0
    
    /// Default constructor
    public init () {
        // empty constructor
    }
    
    
    /// Fully populated constructor
    ///
    /// :param: intervals
    ///         The intervals of work and rest that comprise the schedule
    /// :param: restBetweenIntervals
    ///         Convenience for specifying a common rest interval between the work intervals
    /// :param: numberOfRepetitions
    ///         Convenience for specifying a repetition if the intervals repeat
    /// :param: restBetweenRepetitions
    ///         Convenience for specifying a common rest between interval repeats
    
    public init (intervals : Array<TimerInterval>, restBetweenIntervals : Int, numberOfRepetitions : Int, restBetweenRepetitions : Int) {
        self.intervals = intervals
        self.restBetweenIntervals = restBetweenIntervals
        self.numberOfRepetitions = numberOfRepetitions
        self.restBetweenRepetitions = restBetweenRepetitions
    }
}