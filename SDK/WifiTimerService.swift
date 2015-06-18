//
//  WifiTimerService.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-05.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

@objc class WifiTimerService : TimerService {
    
    private var _deviceCommunicationModule : WifiDeviceCommunicationModule
    
    // Timer specific
    private var _hardwareVersion : Int = 0
    private var _softwareVersion : Int = 0
    
    private var _power : Bool = true
    
    private var _secureMode : SecureMode = .None
    private var _secured : Bool = false
    
    private var _deviceName : String
    
    private var _12h : Bool = true
    private var _showClockSeconds : Bool = false
    private var _timeZoneOffset : Int = -60 * 5
    private var _timeZonePositive : Bool = false
    
    private var _statusMode : StatusMode = .None
    private var _displayMode : DisplayMode = .Clock
    private var _mute : Bool = false
    private var _continuity : Bool = false
    private var _direction : Bool = false
    private var _segue : Bool = false
    private var _prelude : Int = 10
    
    private var _running : Bool = false
    private var _started : Bool = false
    private var _finished : Bool = false
    
    
    // Constructor
    init(deviceCommunicationModule: WifiDeviceCommunicationModule) {
        _deviceCommunicationModule = deviceCommunicationModule
        _deviceName = "Unknown"
        // TODO: set delegate
    }
    
    var id : String {
        get {
            return TIMER_SERVICE_ID
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // INFORMATION
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    var hardwareVersion : Int {
        get {
            return _hardwareVersion
        }
    }
    
    var softwareVersion : Int {
        get {
            return _softwareVersion
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // STARTUP/POWER
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    
    func seedClock(seed : Int) -> Bool
    {
        return _doCommand("XC?\(seed)");
    }
    
    func seedTimer(seed : Int) -> Bool
    {
        return _doCommand("XT?\(seed)");
    }
    
    var power : Bool {
        get {
            return _power
        }
    }
    
    func setPower(b : Bool) -> Bool {
        return b ? powerOn() : powerOff()
    }
    
    func togglePower() -> Bool {
        return _doCommand("@P")
    }
    
    func powerOn() -> Bool {
        return _doCommand("P1")
    }
    
    func powerOff() -> Bool {
        return _doCommand("P0")
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // ADMINISTRATION
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    var deviceName : String {
        get {
            return _deviceName
        }
    }
    
    func setDeviceName(deviceName : String) -> Bool {
        return _doCommand("NM?\(deviceName)")
    }
    
    var secured : Bool {
        get {
            return _secured
        }
    }
    
    func verifySecureCode(secureCode : String) -> Bool {
        return _doCommand("VS?\(secureCode)")
    }
    
    func setSecureCode(secureCode: String) -> Bool {
        return _doCommand("SS?\(secureCode)")
    }
    
    var secureMode : SecureMode {
        get {
            return _secureMode
        }
    }
    
    func setSecureModeNone() -> Bool {
        return _doCommand("SN")
    }
    
    func setSecureModeAdmin() -> Bool {
        return _doCommand("SA")
    }
    
    func setSecureModeAll() -> Bool {
        return _doCommand("SL")
    }
    
    
    
    var twelveHourClock : Bool {
        get {
            return _12h
        }
    }
    
    func toggleTwelveHourClock() -> Bool {
        return _doCommand("@H")
    }
    
    func setTwelveHourClock(b : Bool) -> Bool {
        return b ? twelveHourClockOn() : twelveHourClockOff()
    }
    
    func twelveHourClockOn() -> Bool {
        return _doCommand("H1")
    }
    
    func twelveHourClockOff() -> Bool {
        return _doCommand("H0")
    }
    
    var showClockSeconds : Bool {
        get {
            return _showClockSeconds
        }
    }
    
    func toggleShowClockSeconds() -> Bool {
        return _doCommand("@S")
    }
    
    func setShowClockSeconds(b : Bool) -> Bool {
        return b ? showClockSecondsOn() : showClockSecondsOff()
    }
    
    func showClockSecondsOn() -> Bool {
        return _doCommand("S1")
    }
    
    func showClockSecondsOff() -> Bool {
        return _doCommand("S0")
    }
    
    
    var timeZoneOffset : Int {
        get {
            return _timeZoneOffset
        }
    }
    
    func setTimeZoneOffset(offset : Int) -> Bool {
        var h : Int = offset / 60;
        var m : Int = offset % 60;
        
        return _doCommand("TZ?\(h),\(m)")
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // GENERAL
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    var displayMode : DisplayMode {
        get {
            return _displayMode
        }
    }
    
    func setDisplayModeClock() -> Bool {
        return _doCommand("CL")
    }
    
    func setDisplayModeTimer() -> Bool {
        return _doCommand("TI")
    }
    
    func setDisplayModeMessage() -> Bool {
        return _doCommand("ME")
    }
    
    var statusMode : StatusMode {
        get {
            return _statusMode
        }
    }
    
    func setStatusModeCustom() -> Bool {
        return _doCommand("CU")
    }
    
    func setStatusModeInterval() -> Bool {
        return _doCommand("IN")
    }
    
    func setStatusModeRepetition() -> Bool {
        return _doCommand("IL")
    }
    
    func setStatusModeNone() -> Bool {
        return _doCommand("NO")
    }
    
    var mute : Bool {
        get {
            return _mute
        }
    }
    
    func toggleMute() -> Bool {
        return _doCommand("@M")
    }
    
    func setMute(b : Bool) -> Bool {
        return b ? muteOn() : muteOff()
    }
    
    func muteOn() -> Bool {
        return _doCommand("M1")
    }
    
    func muteOff() -> Bool {
        return _doCommand("M0")
    }
    
    var segue : Bool {
        get {
            return _segue
        }
    }
    
    
    func setSegue(b : Bool) -> Bool {
        return b ? segueOn() : segueOff()
    }
    
    func toggleSegue() -> Bool {
        return _doCommand("@S")
    }
    
    func segueOn() -> Bool {
        return _doCommand("S1")
    }
    
    func segueOff() -> Bool {
        return _doCommand("S0")
    }
    
    var direction : Bool {
        get {
            return _direction
        }
    }
    
    func setDirection(b : Bool) -> Bool {
        return b ? directionUp() : directionDown()
    }
    
    func toggleDirection() -> Bool {
        return _doCommand("@D")
    }
    
    func directionUp() -> Bool {
        return _doCommand("D1")
    }
    
    func directionDown() -> Bool {
        return _doCommand("D0")
    }
    
    var prelude : Int {
        get {
            return _prelude
        }
    }
    
    func setPrelude(prelude : Int) -> Bool {
        return _doCommand("PR?\(prelude)")
    }
    
    var running : Bool {
        get {
            return _running
        }
    }
    
    var started : Bool {
        get {
            return _started
        }
    }
    
    var finished : Bool {
        get {
            return _finished
        }
    }
    
    func start() -> Bool {
        return _doCommand("_S")
    }
    
    func pause() -> Bool {
        return _doCommand("_P")
    }
    
    func reset() -> Bool {
        return _doCommand("_R")
    }
    
    func clear() -> Bool {
        return _doCommand("_C")
    }
    
    
    func buzz(long : Bool) -> Bool
    {
        return _doCommand("ZZ?" + (long ? "1" : "0"))
    }
    
    func buzzRaw(duration : Int) -> Bool
    {
        return _doCommand("ZR?\(duration)")
    }
    
    func setMessage(message : String) -> Bool
    {
        return _doCommand("XM?\(message)")
    }
    
    func setMessageRaw(message : Array<Int>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append("XR?")
        
        var first = true
        for i in message {
            
            sb.append("\(i)")
            
            if (!first) {
                sb.append(",")
            }
            first = false
        }
        
        return _doCommand(sb.toString())
    }
    
    func flashMessage(duration : Int, message : String) -> Bool
    {
        return _doCommand("FM?\(message)")
    }
    
    func flashMessageRaw(duration : Int, message : Array<Int>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append("FR?")
        
        var first = true
        for i in message {
            
            sb.append("\(i)")
            
            if (!first) {
                sb.append(",")
            }
            first = false
        }
        
        return _doCommand(sb.toString())
    }
    
    func setCustomStatus(status : String) -> Bool
    {
        return _doCommand("ST?\(status)")
    }
    
    func setCustomStatusRaw(status : Array<Int>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append("SR?")
        
        var first = true
        for i in status {
            
            if (!first) {
                sb.append(",")
            }
            sb.append("\(i)")
            
            first = false
        }
        
        return _doCommand(sb.toString())
    }
    


    
    func setSchedule(reset: Bool, prelude: Int, segue: Bool, continuous : Bool, statusMode: StatusMode, schedule : TimerSchedule) -> Bool
    {
        return setSchedules(reset, prelude: prelude, segue: segue, continuous: continuous, statusMode: statusMode, schedules: [schedule])
    }
    
    func setSchedules(reset: Bool, prelude: Int,  segue: Bool, continuous : Bool, statusMode: StatusMode, schedules : Array<TimerSchedule>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append(reset ? "_R;" : "")
        sb.append("PR?\(prelude);")
        sb.append(continuous ? "C1;" : "C0;")
        if (statusMode == .None) {
            sb.append("NO;")
        }
        else if (statusMode == .Interval) {
            sb.append("IN;")
        }
        else if (statusMode == .Repetition) {
            sb.append("IL;")
        }
        else if (statusMode == .Custom) {
            sb.append("CU;")
        }
        sb.append("SC?")
        
        for schedule in schedules {
            sb.append("\(schedule.intervals.count),")
            sb.append("\(schedule.restBetweenIntervals),")
            sb.append("\(schedule.numberOfRepetitions),")
            sb.append("\(schedule.restBetweenRepetitions),")
            
            for interval in schedule.intervals {
                if (interval.intervalType == .Work) {
                    sb.append("\(interval.duration)")
                }
                else if (interval.intervalType == .Rest) {
                    sb.append("R\(interval.duration)")
                }
            }
            sb.append("|")
        }
        return _doCommand(sb.toString())
    }
    
    
    private func _doCommand(command : String) -> Bool {
        var (responseCode, result) = _deviceCommunicationModule.sendCommand(command)
        if (responseCode == .Success) {
            return _parseResponse(result)
        }
        return false
    }
    
    // TODO: From delegate

    
    private func _parseResponse(data : Array<UInt8>?) -> Bool
    {
        return false
    }
}