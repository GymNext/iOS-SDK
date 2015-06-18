//
//  BluetoothLETimerService.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-05.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth


class BluetoothLETimerService : TimerService, BluetoothLEService {
    
    private static let RFDUINO = true
    private static let SEND_LIMIT = 20
    
    private var _sendingInitialCommunication = false
    
    // Provided
    private var _secureCode : String?
    private var _deviceName : String
    private var _peripheral : CBPeripheral

    // Info
    private var _hardwareVersion : Int = 0
    private var _softwareVersion : Int = 0
    
    private var _power : Bool = true

    private var _secureMode : SecureMode = .None
    private var _secured : Bool = false
    
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
    
    // Internal
    private var _rxCharacteristic : CBCharacteristic?
    private var _txCharacteristic : CBCharacteristic?
    
    private var _btleCommandQueue = Array<BluetoothLEOperation>()
    private let _lockQueue = dispatch_queue_create("com.gymnext.queue", nil)

    class var serviceUUID : CBUUID {
        get {
        return RFDUINO ? CBUUID(string: "028c8db0-fb17-11e4-a322-1697f925ec7b")
            : CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
        }
    }
    
    class var txCharacteristicUUID : CBUUID {
        get {
            return RFDUINO ? CBUUID(string: "028c8db2-fb17-11e4-a322-1697f925ec7b")
                : CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
        }
    }
    
    class var rxCharacteristicUUID : CBUUID {
        get {
            return RFDUINO ? CBUUID(string: "028c8db1-fb17-11e4-a322-1697f925ec7b")
            : CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
        }
    }

    // Constructor
    init(secureCode : String?, peripheral : CBPeripheral) {
        _peripheral = peripheral
        _secureCode = secureCode
        _deviceName = _peripheral.name
    }
    
    var serviceUUID : CBUUID {
        get {
            return BluetoothLETimerService.serviceUUID
        }
    }
    
    var id : String {
        get {
            return TIMER_SERVICE_ID
        }
    }
    
    var sendingInitialCommunication : Bool {
        get {
            return _sendingInitialCommunication
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
        return _doCommand("@E")
    }
    
    func setShowClockSeconds(b : Bool) -> Bool {
        return b ? showClockSecondsOn() : showClockSecondsOff()
    }
    
    func showClockSecondsOn() -> Bool {
        return _doCommand("E1")
    }
    
    func showClockSecondsOff() -> Bool {
        return _doCommand("E0")
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
            if (!first) {
                sb.append(",")
            }

            sb.append("\(i)")
            first = false
        }
        
        return _doCommand(sb.toString())
    }
    
    func flashMessage(duration : Int, message : String) -> Bool
    {
        return _doCommand("FM?\(duration),\(message)")
    }

    func flashMessageRaw(duration : Int, message : Array<Int>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append("FR?(duration)")
        
        for i in message {
            sb.append(",\(i)")
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

    func setSchedules(reset: Bool, prelude: Int, segue: Bool, continuous : Bool, statusMode: StatusMode, schedules : Array<TimerSchedule>) -> Bool
    {
        var sb : StringBuilder = StringBuilder()
        sb.append(reset ? "_R;" : "")
        sb.append("PR?\(prelude);")
        sb.append(segue ? "S1;" : "S0;")
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
        if (!BluetoothLETimerService.RFDUINO) {
            sb.append("1,") // legacy
        }

        var first = true
        for schedule in schedules {
            if (!first) {
                sb.append("|")
            }

            sb.append("\(schedule.intervals.count),")
            sb.append("\(schedule.restBetweenIntervals),")
            sb.append("\(schedule.numberOfRepetitions),")
            sb.append("\(schedule.restBetweenRepetitions),")
        
            var first2 = true
            for interval in schedule.intervals {
                if (!first2) {
                    sb.append(",")
                }
                
                if (interval.intervalType == .Work) {
                    sb.append("\(interval.duration)")
                }
                else if (interval.intervalType == .Rest) {
                    sb.append("R\(interval.duration)")
                }
                first2 = false
            }
            
            first = false
        }
        return _doCommand(sb.toString())
    }

    private func _doCommand(command : String) -> Bool {
        println("Write \(command)")
        return _writeString(command + ";")
    }
    
    func didDiscoverService(service: CBService!) {
        _peripheral.discoverCharacteristics([BluetoothLETimerService.txCharacteristicUUID, BluetoothLETimerService.rxCharacteristicUUID], forService:service)
    }

    func didDiscoverCharacteristicsForService(service: CBService!)
    {
        println("Characteristics for service \(service.characteristics.count)")

        for c in (service.characteristics as! [CBCharacteristic]) {
            println("Characteristic is \(c.UUID)")
            switch c.UUID {
                case BluetoothLETimerService.rxCharacteristicUUID:         //"6e400003-b5a3-f393-e0a9-e50e24dcca9e"
                    println("Characteristic is RX \(BluetoothLETimerService.rxCharacteristicUUID)")
                    _rxCharacteristic = c
                    _peripheral.setNotifyValue(true, forCharacteristic: _rxCharacteristic)
                    break
                case BluetoothLETimerService.txCharacteristicUUID:         //"6e400002-b5a3-f393-e0a9-e50e24dcca9e"
                    println("Characteristic is TX \(BluetoothLETimerService.txCharacteristicUUID)")
                    _txCharacteristic = c
                    break
                default:
                    break
            }
        }
        
        _sendInitialCommunication()
    }
    
    func didUpdateValueForCharacteristic(characteristic: CBCharacteristic!)
    {
        if (characteristic == _rxCharacteristic) {

            let dataLength:Int = characteristic.value.length
            var data = [UInt8](count: dataLength, repeatedValue: 0)
            characteristic.value.getBytes(&data, length: dataLength)
            
            println(data)
            if (BluetoothLETimerService.RFDUINO && data.count >= 10)
            {
                let result : UInt8! = data[0]
                
                if (result != 0 ) {
                    // error
                    return
                }
                
                // Byte 0 - request result
                // Byte 1 - timer settings
                // Byte 2 - timer settings
                // Byte 3 - prelude
                // Byte 4 - timezone H
                // Byte 5 - timezone M
                // Byte 6 - timer mode
                
                let state : UInt8! = data[1]
                let state2 : UInt8! = data[2]
                
                // bit 0 - success
                // bit 1 - display mode
                // bit 2 - mute
                // bit 3 - 12h/24h
                // bit 4 - up/down
                // bit 5 - continuous/interval
                // bit 6 - started
                // bit 7 - running
                
                if (state & 1 == 1) {
                    self._displayMode = .Timer
                }
                else if (state & 2 == 2) {
                    self._displayMode = .Message
                }
                else {
                    self._displayMode = .Clock
                }

                self._mute = state & 4 == 4
                self._direction = state & 8 == 8
                self._continuity = state & 16 == 16
                self._started = state & 32 == 32
                self._running = state & 64 == 64
                self._finished = state & 128 == 128
                
                println("Started \(_started)")
                println("Running \(_running)")
                println("Finished \(_finished)")
                
                self._timeZonePositive = state2 & 1 == 1
                self._segue = state2 & 2 == 2
                self._power = state2 & 4 == 4
                self._showClockSeconds = state2 & 8 == 8
                self._secured = state2 & 16 == 16
                self._12h = state2 & 32 == 32
                
                if (self._timeZonePositive) {
                    self._timeZoneOffset = Int(data[4]) * 60 + Int(data[5])
                }
                else {
                    self._timeZoneOffset = (Int(data[4]) * Int(60) + Int(data[5])) * Int(-1)
                }
                
                self._prelude  = Int(data[3])
                
                if (Int(data[6]) == 0) {
                    self._secureMode = .None
                }
                else if (Int(data[6]) == 1) {
                    self._secureMode = .Admin
                }
                else if (Int(data[6]) == 2) {
                    self._secureMode = .All
                }

                if (Int(data[7]) == 0) {
                    self._statusMode = .None
                }
                else if (Int(data[7]) == 1) {
                    self._statusMode = .Interval
                }
                else if (Int(data[7]) == 2) {
                    self._statusMode = .Repetition
                }
                else if (Int(data[7]) == 3) {
                    self._statusMode = .Custom
                }

                self._hardwareVersion = Int(data[8])
                self._softwareVersion = Int(data[9])

                _sendingInitialCommunication = false
            }
            else if (!BluetoothLETimerService.RFDUINO && data.count >= 7)
            {
                let result : UInt8! = data[0]
                
                if (result != 0 ) {
                    // error
                    return
                }
                
                // Byte 0 - request result
                // Byte 1 - timer settings
                // Byte 2 - timer settings
                // Byte 3 - prelude
                // Byte 4 - timezone H
                // Byte 5 - timezone M
                // Byte 6 - timer mode
                
                let state : UInt8! = data[1]
                let state2 : UInt8! = data[2]
                
                // bit 0 - success
                // bit 1 - display mode
                // bit 2 - mute
                // bit 3 - 12h/24h
                // bit 4 - up/down
                // bit 5 - continuous/interval
                // bit 6 - started
                // bit 7 - running
                
            
                //self._display = state & 1 == 1
                self._mute = state & 2 == 2
                self._12h = state & 4 == 4
                self._direction = state & 8 == 8
                self._continuity = state & 16 == 16
                self._started = state & 32 == 32
                self._running = state & 64 == 64
                self._finished = state & 128 == 128
                
                self._timeZonePositive = state2 & 1 == 1
                self._segue = state2 & 2 == 2
                self._power = state2 & 4 == 4
                
                if (self._timeZonePositive) {
                    self._timeZoneOffset = Int(data[4]) * 60 + Int(data[5])
                }
                else {
                    self._timeZoneOffset = (Int(data[4]) * Int(60) + Int(data[5])) * Int(-1)
                }
                
                self._prelude  = Int(data[3])
                
                _sendingInitialCommunication = false
            }
        }
    }

    func didUpdateValueForDescriptor(descriptor: CBDescriptor!)
    {
        // Ignored
    }
    
    func didWriteValueForCharacteristic(characteristic: CBCharacteristic!)
    {
        println("wrote characteristic")
        _popQueue()
    }
    
    func didWriteValueForDescriptor(descriptor: CBDescriptor!)
    {
        println("wrote descriptor")
        _popQueue()
    }

    
    func _writeString(string:NSString) -> Bool {
        
        let data = NSData(bytes: string.UTF8String, length: string.length)
        //Send data to peripheral
        
        if (_txCharacteristic == nil){
            println(self, "writeRawData - Unable to write data without txcharacteristic")
            return false
        }
        
        //send data in lengths of <= 20 bytes
        let dataLength = data.length
        
        //Below limit, send as-is
        if dataLength <= BluetoothLETimerService.SEND_LIMIT {
            _addCharacteristicWriteToQueue(_txCharacteristic!, data: data)
            if (!BluetoothLETimerService.RFDUINO) {
                _popQueue();
            }
        }
            
            //Above limit, send in lengths <= 20 bytes
        else {
            
            var len = BluetoothLETimerService.SEND_LIMIT
            var loc = 0
            var idx = 0 //for debug
            
            while loc < dataLength {
                
                var rmdr = dataLength - loc
                if rmdr <= len {
                    len = rmdr
                }
                
                let range = NSMakeRange(loc, len)
                var newBytes = [UInt8](count: len, repeatedValue: 0)
                data.getBytes(&newBytes, range: range)
                let newData = NSData(bytes: newBytes, length: len)
                _addCharacteristicWriteToQueue(_txCharacteristic!, data: newData)
                if (!BluetoothLETimerService.RFDUINO) {
                    _popQueue();
                }
                loc += len
                idx += 1
            }
        }
        
        return true
    }
    
    
    private func _sendInitialCommunication()
    {
        _sendingInitialCommunication = true
        
        let date = NSDate()
        var calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0)

        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
        let hour = components.hour
        let min = components.minute
        let secs = components.second

        var command = ""
        if (_secureCode != nil) {
            command += "VS?\(_secureCode!);"
        }
        else {
            command += "VS?0000;"
        }
        command += "XC?\(hour * 3600 + min * 60 + secs);"
        command += "P1;"
        command += "XX" // Last command must be status request since it can be run in secure and non-secure modes

        _doCommand(command)
        
    }
    
    
    private func _addCharacteristicWriteToQueue(characteristic : CBCharacteristic, data: NSData) {
        
        dispatch_sync(_lockQueue) {
            self._btleCommandQueue.append(BluetoothLEOperation(characteristic: characteristic, value: data));
        
            if (self._btleCommandQueue.count == 1) {
                self._peripheral.writeValue(data, forCharacteristic: characteristic, type:BluetoothLETimerService.RFDUINO ? .WithResponse : .WithoutResponse)
            }
        }
    }

    private func _addDescriptorWriteToQueue(descriptor : CBDescriptor, data: NSData) {
        
        dispatch_sync(_lockQueue) {
            self._btleCommandQueue.append(BluetoothLEOperation(descriptor: descriptor, value: data));
        
            if (self._btleCommandQueue.count == 1) {
                self._peripheral.writeValue(data, forDescriptor: descriptor)
            }
        }
        
    }

    private func _popQueue() {
       
        dispatch_sync(_lockQueue) {
            // pop
            self._btleCommandQueue.removeAtIndex(0)
            
            if (self._btleCommandQueue.count > 0) {
                
                let command = self._btleCommandQueue[0]
                if (command.descriptor != nil) {
                    self._peripheral.writeValue(command.value, forDescriptor: command.descriptor)
                }
                else {
                    self._peripheral.writeValue(command.value, forCharacteristic: command.characteristic, type:BluetoothLETimerService.RFDUINO ? .WithResponse : .WithoutResponse)
                }
            }
        }
        
    }
    



}
    