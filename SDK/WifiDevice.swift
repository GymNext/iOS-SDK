//
//  WifiDevice.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

class WifiDevice : Device {
    
    private let KEY_IP_ADDRESS = "ipAddress"
    private let KEY_PORT = "port"
    private let KEY_MAC_ADDRESS = "macAddress"
    
    class func create(deviceId: String, deviceName: String, deviceAlias : String?, manufacturerName: String, modelName: String, ipAddress: String, port: Int, macAddress: String) ->  WifiDevice {
        return WifiDevice(deviceId: deviceId, deviceName: deviceName, deviceAlias: deviceAlias, manufacturerName: manufacturerName, modelName: modelName, ipAddress: ipAddress, port: port, macAddress: macAddress)
    }
    
    private var _ipAddress : String
    private var _port : Int
    private var _macAddress : String

    private var _deviceCommunicationModule : WifiDeviceCommunicationModule?
    private var _services : Array<Service> = Array<Service>()

    init(deviceId: String, deviceName: String, deviceAlias: String?, manufacturerName : String, modelName: String, ipAddress: String, port: Int, macAddress: String) {
        _ipAddress = ipAddress
        _port = port
        _macAddress = macAddress
        super.init(deviceId: deviceId, deviceName: deviceName, deviceAlias: deviceAlias, manufacturerName: manufacturerName, modelName: modelName)

        _deviceCommunicationModule = WifiDeviceCommunicationModule(device: self)
    }
    
    required init(coder aDecoder: NSCoder) {
        _ipAddress = aDecoder.decodeObjectForKey(KEY_IP_ADDRESS) as! String
        _port = aDecoder.decodeIntegerForKey(KEY_PORT)
        _macAddress = aDecoder.decodeObjectForKey(KEY_MAC_ADDRESS) as! String
        super.init(coder: aDecoder)

        _deviceCommunicationModule = WifiDeviceCommunicationModule(device: self)
    }
    
    var ipAddress : String {
        get {
            return _ipAddress
        }
        set {
            _ipAddress = newValue
        }
    }
    
    var port : Int {
        get {
            return _port
        }
    }
    
    var macAddress : String {
        get {
            return _macAddress
        }
    }
    
    override var communicationMethod : CommunicationMethod {
        get {
            return CommunicationMethod.Wifi
        }
    }
    
    override func getService(serviceId : String) -> Service {
        // Abstract - override in subclass
        return nil as Service!
    }
    
    override var connected : Bool {
        get {
            // Abstract - override in subclass
            return false
        }
    }
    
    override func connect() {
        // Abstract - override in subclass
    }
    
    override func disconnect() {
        // Abstract - override in subclass
    }
    
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(_ipAddress, forKey:KEY_IP_ADDRESS)
        aCoder.encodeInteger(_port, forKey:KEY_PORT)
        aCoder.encodeObject(_macAddress, forKey:KEY_MAC_ADDRESS)
    }
    
}