//
//  Device.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The various states of a device connection
public enum DeviceState : Int {
    
    /// can't communicate with device at all or device is in use
    case OutOfRange = 0,
    /// device is in range, but not connected
    Disconnected = 1,
    /// we are establishing a connection
    Connecting = 2,
    /// we are actively connected
    Connected = 3
}

/// Main listener for this device
public protocol DeviceDelegate {
    
    // Device connection
    ///
    /// Callback for when communication channel has been established with the device
    ///
    /// :param: device
    ///     the device
    ////
    func establishedCommunicationChannel(device: Device!)
    
    // Device Communication
    ///
    /// Callback for when data has been sent to the device
    ///
    /// :param: device
    ///     the device
    ////
    func sentDataToDevice(device: Device!)
    ///
    /// Callback for when data has been received by the device
    ///
    /// :param: device
    ///     the device
    ////
    func receivedDataFromDevice(device: Device!)
}

/// Base class for all devices that you can connect to.  Connecting to a device allows you
/// to access the service interfaces that device supports.  Then using these interfaces
///  you can request the device perform some action or provide some data.
public class Device : NSObject, NSCoding {
    
    let KEY_DEVICE_ID = "deviceId"
    let KEY_DEVICE_NAME = "deviceName"
    let KEY_DEVICE_ALIAS = "deviceAlias"
    let KEY_MANUFACTURER_NAME = "manufacturerName"
    let KEY_MODEL_NAME = "modelName"
    let KEY_SERVICE_IDS = "serviceIds"
    
    private var _delegate : DeviceDelegate?
    private var _deviceId : String
    private var _deviceState : DeviceState
    private var _manufacturerName : String
    private var _modelName : String
    private var _deviceName : String
    private var _deviceAlias : String?
    private var _serviceIds : [String] = []
    
    /// Construct a device
    ///
    /// :param: deviceId
    ///     Unique id of the device
    /// :param: deviceName
    ///     The name of the device
    /// :param: deviceAlias
    ///     Local override of the device name
    /// :param: manufacturerName
    ///     Manufacturer of the device
    /// :param: modelName
    ///     Model name of the device
    ///
    init(deviceId: String, deviceName: String, deviceAlias: String?, manufacturerName : String, modelName: String) {
        _deviceId = deviceId
        _deviceName = deviceName
        _deviceAlias = deviceAlias
        _manufacturerName = manufacturerName
        _modelName = modelName
        _deviceState = .OutOfRange
    }
    
    /// Internal constructor for loading from NSCoder format
    public required init(coder aDecoder: NSCoder) {
        _deviceId = aDecoder.decodeObjectForKey(KEY_DEVICE_ID) as! String
        _deviceName = aDecoder.decodeObjectForKey(KEY_DEVICE_NAME) as! String
        _deviceAlias = aDecoder.decodeObjectForKey(KEY_DEVICE_ALIAS) as! String?
        _manufacturerName = aDecoder.decodeObjectForKey(KEY_MANUFACTURER_NAME) as! String
        _modelName = aDecoder.decodeObjectForKey(KEY_MODEL_NAME) as! String
        _serviceIds = aDecoder.decodeObjectForKey(KEY_SERVICE_IDS) as! [String]
        _deviceState = .OutOfRange
    }
    
    ///
    /// Retrieve the device's delegate
    ///
    /// :returns:
    ///     The device delegate
    ///
    public var delegate : DeviceDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }
    
    ///
    /// Retrieve the device id
    ///
    /// :returns:
    ///     unique device id
    ///
    public var deviceId : String {
        get {
            return _deviceId
        }
    }
    
    ///
    /// Retrieve the device name
    ///
    /// :returns:
    ///     The name of the device
    ///
    internal(set) public var deviceName : String {
        get {
            return _deviceName
        }
        set {
            _deviceName = newValue
        }
    }
    
    ///
    /// Retrieve the device alias
    ///
    /// :returns:
    ///     the alias of the device
    ///
    internal(set) public var deviceAlias : String? {
        get {
            return _deviceAlias
        }
        set {
            _deviceAlias = newValue
        }
    }
    
    ///
    /// Retrieve the name of the device to display to the user.  Uses alias if set, otherwise
    /// device name.
    ///
    /// :returns:
    ///     The display name of the device
    ///
    public var displayName : String {
        get {
            if (_deviceAlias == nil || count(_deviceAlias!) == 0) {
                return _deviceName
            }
            return _deviceAlias!
        }
    }
    
    ///
    /// Get the manufacturer name (if known)
    ///
    /// :returns:
    ///     the name of the manufacturer
    ///
    public var manufacturerName : String {
        get {
            return _manufacturerName
        }
    }
    
    ///
    /// Ge the model name (if known)
    ///
    /// :returns:
    ///     the name of the model
    ///
    public var modelName : String {
        get {
            return _modelName
        }
    }
    
    ///
    /// Retrieve the state of the device
    ///
    /// :returns:
    ///     The device state
    ///
    internal(set) public var deviceState : DeviceState {
        get {
            return _deviceState
        }
        set {
            _deviceState = newValue
        }
    }

    ///
    /// Retrieve the services supported by this device
    ///
    /// :returns:
    ///     The services this device supports
    ///
    internal(set) public var serviceIds : [String] {
        get {
            return _serviceIds
        }
        set {
            _serviceIds = newValue
        }
    }
    
    ///
    /// The communication method used by this device
    ///
    /// :returns:
    ///     The communication method
    ///
    public var communicationMethod : CommunicationMethod {
        get {
            // Abstract - override in subclass
            return nil as CommunicationMethod!
        }
    }
    
    ///
    /// Check if the device supports a given service
    ///
    /// :param: serviceId
    ///     The service to check
    /// :returns:
    ///     true if the service is supported
    ///
    public func hasService(serviceId : String) -> Bool {
        for id in _serviceIds {
            if (id == serviceId) {
                return true
            }
        }
        return false
    }

    ///
    /// The implementation of the service interface for this device
    ///
    /// :param: serviceId
    ///     The service to retrieve
    /// :returns:
    ///     The service to use
    ///
    public func getService(serviceId : String) -> Service {
        // Abstract - override in subclass
        return nil as Service!
    }
    
    ///
    /// Retrieve if the device is connected
    ///
    /// :returns:
    ///     If the device is connected
    ///
    public var connected : Bool {
        get {
            return _deviceState == .Connected
        }
    }
    
    ///
    /// Retrieve if the device is in range
    ///
    /// :returns:
    ///     If the device is in range
    ///
    public var inRange : Bool {
        get {
            return _deviceState != .OutOfRange
        }
    }
    
    
    ///
    /// Connect to the device
    ///
    func connect() {
        // Abstract - override in subclass
    }
    
    ///
    /// Disconnect from the device
    ///
    func disconnect() {
        // Abstract - override in subclass
    }
    
    ///
    /// Internal callback for did connect
    ///
    func didConnect() {
        // Abstract - override in subclass
    }
    
    ///
    /// Internal callback for did disconnect
    ///
    func didDisconnect() {
        // Abstract - override in subclass
    }

    ///
    /// Internal callback for did fail to connect
    ///
    func didFailToConnect() {
        // Abstract - override in subclass
    }
    
    ///
    /// Internal callback for did move into range
    ///
    func didMoveIntoRange() {
        // Abstract - override in subclass
    }

    ///
    /// Internal callback for did move out of range
    ///
    func didMoveOutOfRange() {
        // Abstract - override in subclass
    }


    /// Internal method for saving to encoder
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_deviceId, forKey:KEY_DEVICE_ID)
        aCoder.encodeObject(_deviceName, forKey:KEY_DEVICE_NAME)
        aCoder.encodeObject(_deviceAlias, forKey:KEY_DEVICE_ALIAS)
        aCoder.encodeObject(_manufacturerName, forKey:KEY_MANUFACTURER_NAME)
        aCoder.encodeObject(_modelName, forKey:KEY_MODEL_NAME)
        aCoder.encodeObject(_serviceIds, forKey:KEY_SERVICE_IDS)
    }
    
    
    
}