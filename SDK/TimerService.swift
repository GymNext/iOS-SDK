//
//  TimerService.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-05.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// Provides access to the internal state of the timer and actions that it can perform
public protocol TimerService : Service {
    
    // Information

    /// Retrieve the hardware version of the timer.
    ///
    /// :returns:
    ///     The hardware version id
    var hardwareVersion : Int { get }

    ///Retrieve the software version running on the timer.
    ///
    /// :returns:
    ///     The software version id
    var softwareVersion : Int { get }
    
    // Startup/Power
    
    ///
    /// Asynchronous Request - Seed the clock with the current time in seconds
    ///
    /// :param: seed
    ///     The current UTC time in seconds for the day
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func seedClock(seed : Int) -> Bool
    
    ///
    /// Asynchronous Request - Seed the timer with the current elapsed time in seconds
    ///
    /// :param: seed
    ///     The current elapsed time (including prelude) in seconds
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func seedTimer(seed : Int) -> Bool

    ///
    /// If the timer is powered on
    ///
    /// :returns:
    ///     If the timer is powered on
    ///
    var power : Bool { get }

    ///
    /// Asynchronous Request - Turn the power on/off based on flag
    ///
    /// :param: power
    ///     flag to turn the power on or off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setPower(b : Bool) -> Bool

    ///
    /// Asynchronous Request - Flip the power on/off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func togglePower() -> Bool

    ///
    /// Asynchronous Request - Turn the power on
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///

    func powerOn() -> Bool

    ///
    /// Asynchronous Request - Turn the power off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func powerOff() -> Bool
    
    // Administration
    ///
    /// The secure mode the timer is currently running in
    ///
    /// :returns:
    ///     The secure mode
    ///
    var secureMode : SecureMode { get }

    ///
    /// Asynchronous Request - Turn secure mode to off
    ///
    /// After this request, all requests will succeed without securing the connection.
    ///
    /// Privileges Required: Admin
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSecureModeNone() -> Bool

    ///
    /// Asynchronous Request - Turn secure mode to admin
    ///
    /// After this request, all requests that require admin privileges will first require that the connection has been secured.
    ///
    /// Privileges Required: Admin
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSecureModeAdmin() -> Bool

    ///
    /// Asynchronous Request - Turn secure mode to all
    ///
    /// After this request, all requests will first require that the connection has been secured.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSecureModeAll() -> Bool

    ///
    /// Asynchronous Request - Change the secure code
    ///
    /// :param: secureCode
    ///     The secure code to change to
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSecureCode(secureCode : String) -> Bool

    ///
    /// Check if the connection has been secured
    ///
    /// :returns:
    ///     if the connection has been secured
    ///
    var secured : Bool { get }

    ///
    /// Asynchronous Request - Verify the secure code and secure the connection
    ///
    /// :param: secureCode
    ///     The secure code to verify
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func verifySecureCode(secureCode : String) -> Bool
    
    ///
    /// Retrieve the name of the device
    /// :returns:
    ///     the name of the device
    ///
    var deviceName : String { get }

    ///
    /// Asynchronous Request - Change the name of the device (7 character max)
    ///
    /// Note:  After this request completes, the timer will reset itself and your connection will be lost.
    ///
    /// :param: deviceName
    ///     The name of the device
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setDeviceName(deviceName : String) -> Bool

    ///
    /// Retrieve if the clock is set for 12 hour or 24 hour display
    ///
    /// :returns:
    ///     twelve hour display enabled
    ///
    var twelveHourClock : Bool { get }

    ///
    /// Asynchronous Request - Toggle if 12h/24h clock display should be used
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func toggleTwelveHourClock() -> Bool

    ///
    /// Asynchronous Request - Set twelve hour clock based on flag
    ///
    /// :param: twelveHourClock
    ///     if twelve hour clock display should be used
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setTwelveHourClock(b : Bool) -> Bool

    ///
    /// Asynchronous Request - Turn twelve hour clock on
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func twelveHourClockOn() -> Bool

    ///
    /// Asynchronous Request - Turn twelve hour clock off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func twelveHourClockOff() -> Bool
    
    ///
    /// Retrieve if the clock should be showing seconds or not.  If the clock is to show seconds, then it will display time
    /// in the format HH:MM:SS.  If not, it will display time in the format HH:MM.
    ///
    /// :returns:
    ///     If the clock is showing seconds
    ///
    var showClockSeconds : Bool { get }

    ///
    /// Asynchronous Request - Flip the toggle seconds options
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func toggleShowClockSeconds() -> Bool

    ///
    /// Asynchronous Request - Set the show clock seconds option based on flag
    ///
    /// :param: showClockSeconds
    ///     Whether or not to show clock seconds
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setShowClockSeconds(b : Bool) -> Bool

    ///
    /// Asynchronous Request - Turn show clock seconds on
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func showClockSecondsOn() -> Bool

    ///
    /// Asynchronous Request - Turn show clock seconds off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func showClockSecondsOff() -> Bool

    ///
    /// Retrieve the current timezone offset in minutes
    ///
    /// :returns:
    ///     The current time zone offset
    ///
    var timeZoneOffset : Int { get }

    ///
    /// Asynchronous Request - Set the timezone offset to use
    ///
    /// :param: offset
    ///     The offset in minutes from UTC
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setTimeZoneOffset(offset : Int) -> Bool

    // General
    ///
    /// Retrieve the current display mode the timer is in
    ///
    /// :returns:
    ///     The current display mode
    ///
    var displayMode : DisplayMode { get }
    ///
    /// Asynchronous Request - Set the display mode to show clock
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setDisplayModeClock() -> Bool
    ///
    /// Asynchronous Request - Set the display mode to show timer
    /// :returns:
    /// True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setDisplayModeTimer() -> Bool
    ///
    /// Asynchronous Request - Set the display mode to show the message
    /// :returns:
    /// True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setDisplayModeMessage() -> Bool
    
    ///
    /// The status mode controls what is displayed in the status digits.  On a 6 digit timer, the two left most digits are used for
    /// status and the 4 right most digits show the time elapsed/remaining.  Refer to the status mode enum for an explanation of each
    /// status mode.
    ///
    /// :returns:
    ///     The current status mode
    ///
    var statusMode : StatusMode { get }
    ///
    /// Asynchronous Request - Controls the status mode that is used when the timer is running.
    ///
    /// By setting the status mode to none, there will be no data shown in the status digits.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setStatusModeNone() -> Bool
    ///
    /// Asynchronous Request - Controls the status mode that is used when the timer is running.
    ///
    /// By setting the status mode to interval, the status digits will show the interval number.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setStatusModeInterval() -> Bool
    ///
    /// Asynchronous Request - Controls the status mode that is used when the timer is running.
    ///
    /// By setting the status mode to repetition, the status digits will show the repetition number.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setStatusModeRepetition() -> Bool
    ///
    /// Asynchronous Request - Controls the status mode that is used when the timer is running.
    ///
    /// By setting the status mode to custom, the status digits will show the values specified via setCustomStatus()
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setStatusModeCustom() -> Bool
    
    ///
    /// Retrieve if the timer is currently muted.  If the timer is muted it will not make any beeps.
    ///
    /// :returns:
    ///     if the timer is muted
    ///
    var mute : Bool { get }
    ///
    /// Asynchronous Request - Toggle if the timer is muted
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func toggleMute() -> Bool
    ///
    /// Asynchronous Request - Set the mute option based on a flag
    ///
    /// :param: mute
    ///     Whether or not to turn on mute
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setMute(b : Bool) -> Bool
    ///
    /// Asynchronous Request - Turn mute on
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func muteOn() -> Bool
    ///
    /// Asynchronous Request - Turn mute off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func muteOff() -> Bool
    
    ///
    /// Retrieve if the segue is on.  If the segue is on, then at the end of each interval and at the end of the program, the last three seconds will feature a beep.
    ///
    /// :returns:
    ///     If the segue is on
    ///
    var segue : Bool { get }
    ///
    /// Asynchronous Request - Toggle the segue
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func toggleSegue() -> Bool
    ///
    /// Asynchronous Request - Set segue based on flag
    ///
    /// :param: segue
    ///     Whether or not to turn on the segue
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSegue(b : Bool) -> Bool
    ///
    /// Asynchronous Request - Turn segue on
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func segueOn() -> Bool
    ///
    /// Asynchronous Request - Turn segue off
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func segueOff() -> Bool
    
    ///
    /// Retrieve if the timer is counting up (showing elapsed time) or counting down (showing remaining time)
    ///
    /// :returns:
    ///     If the timer direction is up
    ///
    var direction : Bool { get }
    ///
    /// Asynchronous Request - Set the direction of the timer based on a flag
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setDirection(b : Bool) -> Bool
    ///
    /// Asynchronous Request - Flip the direction of the timer
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func toggleDirection() -> Bool
    ///
    /// Asynchronous Request - Set the direction of the timer to up (shows elapsed)
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func directionUp() -> Bool
    ///
    /// Asynchronous Request - Set the direction of the timer to down (shows remaining)
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func directionDown() -> Bool
    
    ///
    /// Retrieve the prelude in seconds 0-99).  The prelude is an amount of time that runs before the timer program to allow
    /// everyone to prepare and get in the proper position.
    ///
    /// :returns:
    ///     The prelude in seconds
    ///
    var prelude : Int { get }
    ///
    /// Asynchronous Request - Set the prelude to a specific duration.
    ///
    /// :param: prelude
    ///     the prelude duration in seconds
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setPrelude(prelude : Int) -> Bool
    
    ///
    /// Check if the timer is actively running
    ///
    /// :returns:
    /// If the timer is actively running
    ///
    var running : Bool { get }
    ///
    /// Check if the timer has been started (more than 0 seconds has elapsed)
    ///
    /// :returns:
    ///     If the timer has been started
    ///
    var started : Bool { get }
    ///
    /// Check if the timer has completed its schedule
    ///
    /// :returns:
    ///     If the timer has completed its schedule
    ///
    var finished : Bool { get }
    ///
    /// Asynchronous Request - Start the timers counting sequence.  This will begin with the prelude and then move through the schedules to completion.
    ///
    /// If the timer has been paused, use start to continue.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func start() -> Bool
    ///
    /// Asynchronous Request - Pause the timer from counting.  This will wait at the current timer duration until a start of reset command.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func pause() -> Bool
    ///
    /// Asynchronous Request - Reset timer back to 0 if its not actively running.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func reset() -> Bool
    ///
    /// Asynchronous Request - Reset timer back to 0 regardless of its current state.
    ///
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func clear() -> Bool

    ///
    /// Asynchronous Request - Make the timer buzz
    ///
    /// :param: longBuzz
    ///     if true, a long buzz will occur.  If false, a short buzz.
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func buzz(long : Bool) -> Bool
    ///
    /// Asynchronous Request - Make the timer buzz for a specified duration
    ///
    /// :param: duration
    ///     the duration in milliseconds to make the timer buzz for
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func buzzRaw(duration : Int) -> Bool
    
    ///
    /// Asynchronous Request - Set the message to be displayed when the device is in message mode.  The message
    /// cannot be more than 32 characters and can only use these characters [A-Za-z0-9.-_ and space.
    ///
    /// :param: message
    ///     the message to display
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setMessage(message : String) -> Bool
    ///
    /// Asynchronous Request - Set the message to be displayed when the device is in message mode by specifying the raw value to control the seven segment display.  A seven segment
    /// display is made of 7 separate line segments and a decimal point.  Each is given a numeric value.  To control more than one segment at a time,
    /// simply add the values.
    ///
    /// - top (a) = 4
    /// - top-right (b) = 8
    /// - bottom-right (c) = 32
    /// - bottom (d) = 64
    /// - bottom-left (e) = 128
    /// - top-left (f) = 2
    /// - middle (g) = 1
    /// - decimal point (dp) = 16
    ///
    ///
    /// :param: message
    ///     the message to display
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setMessageRaw(message : Array<Int>) -> Bool

    ///
    /// Asynchronous Request - A flash message appears for 3 seconds (more if it needs to scroll) and then the timer returns back to its previously display setting.
    ///
    /// The message cannot be more than 32 characters and can only use these characters [A-Za-z0-9.-_ and space.
    ///
    /// :param: duration
    ///     the duration (in seconds) to show the message
    /// :param: message
    ///     the message to flash
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func flashMessage(duration : Int, message : String) -> Bool
    ///
    /// Asynchronous Request - A flash message appears for 3 seconds (more if it needs to scroll) and then the timer returns back to its previously display setting.
    ///
    /// Set the flash message to be displayed by specifying the raw value to control the seven segment display.  A seven segment
    /// display is made of 7 separate line segments and a decimal point.  Each is given a numeric value.  To control more than one segment at a time,
    /// simply add the values.
    ///
    /// - top (a) = 4
    /// - top-right (b) = 8
    /// - bottom-right (c) = 32
    /// - bottom (d) = 64
    /// - bottom-left (e) = 128
    /// - top-left (f) = 2
    /// - middle (g) = 1
    /// - decimal point (dp) = 16
    ///
    ///
    /// :param duration
    ///     the duration in seconds to show the message
    /// :param: message
    ///     the message to flash
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func flashMessageRaw(duration : Int, message : Array<Int>) -> Bool

    ///
    /// Asynchronous Request - A custom status appears in the status digits when the status mode is set to custom.
    ///
    /// The status cannot be more than 2 characters and can only use these characters [A-Za-z0-9.-_ and space.
    ///
    /// :param: status
    ///     the status to display
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setCustomStatus(status : String) -> Bool
    ///
    /// Asynchronous Request - A custom status appears in the status digits when the status mode is set to custom.
    ///
    /// Set the custom status by specifying the raw value to control the seven segment display.  A seven segment
    /// display is made of 7 separate line segments and a decimal point.  Each is given a numeric value.  To control more than one segment at a time,
    /// simply add the values.
    ///
    /// - top (a) = 4
    /// - top-right (b) = 8
    /// - bottom-right (c) = 32
    /// - bottom (d) = 64
    /// - bottom-left (e) = 128
    /// - top-left (f) = 2
    /// - middle (g) = 1
    /// - decimal point (dp) = 16
    ///
    /// :param: status
    ///     the status to display
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setCustomStatusRaw(status : Array<Int>) -> Bool
    
    ///
    /// Asynchronous Request - Set the schedule the clock should track.  If the clock is currently running, this will be rejected.
    ///
    /// Each schedule is made up of one or more intervals.  These intervals have a specific duration on which work or rest may be performed.
    /// You can repeat a group of intervals multiple times using the repetition value.  You can use the restAfterInterval and restAfterRepetition values to
    /// specify a rest period which is common to all intervals or repetitions.
    ///
    /// :param: reset
    ///     should we reset the clock before applying this schedule.  If the clock has been started, setting the schedule without a reset will fail.
    /// :param: prelude
    ///     the prelude duration to use with the schedule
    /// :param: segue
    ///     if segue should be enabled for this schedule
    /// :param: continuous
    ///     if the total elapsed/remaining time should be shown, or if the elapsed/remaining time in the current interval should be shown
    /// :param: statusMode
    ///     the type of status to display
    /// :param: schedule
    ///     The actual work durations and rest durations along with repetition and interval schemes
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSchedule(reset: Bool, prelude: Int, segue: Bool, continuous : Bool, statusMode: StatusMode, schedule : TimerSchedule) -> Bool
    ///
    /// Asynchronous Request - Set the schedule the clock should track.  If the clock is currently running, this will be rejected.
    ///
    /// Each schedule is made up of one or more intervals.  These intervals have a specific duration on which work or rest may be performed.
    /// You can repeat a group of intervals multiple times using the repetition value.  You can use the restAfterInterval and restAfterRepetition values to
    /// specify a rest period which is common to all intervals or repetitions.
    ///
    /// With this method, you can specify more than one schedule if necessary.
    ///
    /// :param: reset
    ///     should we reset the clock before applying this schedule.  If the clock has been started, setting the schedule without a reset will fail.
    /// :param: prelude
    ///     the prelude duration to use with the schedule
    /// :param: segue
    ///     if segue should be enabled for this schedule
    /// :param: continuous
    ///     if the total elapsed/remaining time should be shown, or if the elapsed/remaining time in the current interval should be shown
    /// :param: statusMode
    ///     the type of status to display
    /// :param: schedules
    ///     The actual work durations and rest durations along with repetition and interval schemes
    /// :returns:
    ///     True/false based on if the command was accepted.  This does not indicate success/failure of the command.
    ///
    func setSchedules(reset: Bool, prelude: Int, segue: Bool, continuous : Bool, statusMode: StatusMode, schedules : Array<TimerSchedule>) -> Bool
        
    
}
