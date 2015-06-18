//
//  DeviceManager.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Main listener for all events related to device management
public protocol CentralDeviceManagerDelegate
{
    // Device Discovery
    ///
    /// The device moved into range
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidMoveInRange device: Device!)
    ///
    /// The device moved out of range
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidMoveOutOfRange device: Device!)

    // Device Activation
    ///
    /// The device was activated
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidActivate device: Device!)
    ///
    /// The device was deactivated
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidDeactivate device: Device!)
    
    // Device Connection
    ///
    /// The device did connect
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidConnect device: Device!)
    ///
    /// The device did fail to connect
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidFailToConnect device: Device!)
    ///
    /// The device did disconnect
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    /// :param: device
    ///     the device
    ///
    func deviceManager(centralDeviceManager: CentralDeviceManager!, deviceDidDisconnect device: Device!)

    ///
    /// The device manager finished reconnecting
    ///
    /// :param: centralDeviceManager
    ///     the device manager
    ///
    func deviceManagerDidFinishReconnectingDevices(centralDeviceManager: CentralDeviceManager!)
    ///
    /// The device manager finished disconnecting from all devices
    ///
    /// :param: centralDeviceManager
    ///     The device manager
    ///
    func deviceManagerDidFinishDisconnectingDevices(centralDeviceManager: CentralDeviceManager!)
}

/**
* This is the main access point for all device management.  This is where you will discover new devices,
* activate and deactivate devices, and reconnect to devices.  You can also give devices aliases,
* store secure codes so that users don't need to be prompted every time, and can receive updates
* on device state by registering yourself as the delegate.
*
* To talk to a device, you must first activate it.  Once connected, you can use the device object
* to retrieve a specific service it supports and call methods on that service.
*/
public class CentralDeviceManager : BluetoothLEDeviceManagerDelegate, WifiDeviceManagerDelegate {
    
    // Reconnection State
    private var _reconnected = false
    private var _reconnectingDevices = Dictionary<String, Device>()
    private var _disconnectingDevices = Dictionary<String, Device>()

    // Scanning State
    private var _scanning = false
    
    private var _delegate : CentralDeviceManagerDelegate?
    private var _communicationMethods = Dictionary<CommunicationMethod, Bool>()
    
    private var _activeDeviceIds = Array<String>()
    private var _transientInactiveDeviceIds = Array<String>()
    private var _deviceAliases = Dictionary<String, String>()
    private var _deviceSecureCodes = Dictionary<String, String>()
    
    /// Singleton Accessor
    public class var sharedInstance : CentralDeviceManager {
        struct Static {
            static let instance : CentralDeviceManager = CentralDeviceManager()
        }
        return Static.instance
    }

    init() {
        _communicationMethods[CommunicationMethod.Bluetooth] = false // not supported on iOS
        _communicationMethods[CommunicationMethod.Wifi] = false // not fully implemented
        _communicationMethods[CommunicationMethod.BluetoothLE] = true
        
        BluetoothLEDeviceManager.sharedInstance.delegate = self
        WifiDeviceManager.sharedInstance.delegate = self
        
        _loadSettings()
    }
    
    ///
    /// Set the delegate for the manager
    ///
    /// :param: delegate
    ///     The delegate listener
    ///
    public var delegate : CentralDeviceManagerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    // COMMUNICATION METHODS
    
    ///
    /// Check if a specific communication method is enabled
    ///
    /// :param: communicationMethod
    ///     The communication method to check
    /// :returns:
    ///     If the communication method is enabled
    ///
    public func isEnabled(communicationMethod : CommunicationMethod) -> Bool {
        return _communicationMethods[communicationMethod]!
    }

    ///
    /// Enable a communication method
    ///
    /// :param: communicationMethod
    ///     The communication method to enable
    ///
    public func enable(communicationMethod : CommunicationMethod) {
        _communicationMethods[communicationMethod] = true
    }

    ///
    /// Disable a communication method
    ///
    /// :param: communicationMethod
    ///     The communication method to disable
    ///
    ///
    public func disable(communicationMethod : CommunicationMethod) {
        _communicationMethods[communicationMethod] = false
    }
    
    ///
    /// Check if a communication method is even supported by the user's device (aka. phone/tablet)
    ///
    /// :param: communicationMethod
    ///     The communication method to check
    /// :returns:
    ///     If the communication method is available and enabled
    ///
    public func isAvailable(communicationMethod : CommunicationMethod) -> Bool {
        if (communicationMethod == .Bluetooth) {
            return false
        }
        else if (communicationMethod == .BluetoothLE) {
            return BluetoothLEDeviceManager.sharedInstance.available
        }
        else if (communicationMethod == .Wifi) {
            return WifiDeviceManager.sharedInstance.available
        }
        else {
            return false
        }
    }

    // RECONNECT DEVICES
    
    ///
    /// Reconnect to all active devices only if not already trying to reconnect.
    ///
    /// :param: forceActive
    ///     Forces a retry of all active devices even if a previous reconnect attempt failed
    /// :returns:
    ///     If a reconnect attempt can be made.
    ///
    public func reconnectAll(forceActive: Bool) -> Bool {
        
        if (forceActive) {
            _transientInactiveDeviceIds.removeAll()
        }
        
        if (_reconnected) {
            println("skipping reconnection due to already reconnected")
            return false
        }
        
        if (_activeDeviceIds.count == 0) {
            println("skipping reconnect - there are no active devices")
            _reconnected = true
            return false
        }

        println("reconnecting to active devices")

        _reconnected = true
        _reconnectingDevices.removeAll()
        
        if (self.isEnabled(.BluetoothLE)) {
            for device in BluetoothLEDeviceManager.sharedInstance.devices(nil) {
                if (self.isActive(device)) {
                    _reconnectingDevices[device.deviceId] = device
                }
            }
        }
        
        if (self.isEnabled(.Wifi)) {
            for device in WifiDeviceManager.sharedInstance.devices(nil) {
                if (self.isActive(device)) {
                    _reconnectingDevices[device.deviceId] = device
                }
            }
        }

        if (_reconnectingDevices.count == 0) {
            println("skipping reconnect - there are no actual active devices")
            return false
        }

        for (deviceId, device) in _reconnectingDevices {
            self._connect(device)
        }

        return true
    }
    
    ///
    /// Disconnect from all devices
    ///
    public func disconnectAll() {

        _disconnectingDevices.removeAll()

        if (self.isEnabled(.BluetoothLE)) {
            for device in BluetoothLEDeviceManager.sharedInstance.devices(nil) {
                if (self.isActive(device)) {
                    _disconnectingDevices[device.deviceId] = device
                }
            }
        }
        
        if (self.isEnabled(.Wifi)) {
            for device in WifiDeviceManager.sharedInstance.devices(nil) {
                if (self.isActive(device)) {
                    _disconnectingDevices[device.deviceId] = device
                }
            }
        }

        if (_disconnectingDevices.count == 0) {
            if (self._delegate != nil) {
                self._delegate!.deviceManagerDidFinishDisconnectingDevices(self)
            }
        }
        
        for (deviceId, device) in _disconnectingDevices {
            self._disconnect(device)
        }
        
        _reconnected = false
    }


    // DISCOVERY FOR NEW DEVICES

    ///
    /// Start scanning for devices to be discovered.
    ///
    public func startScanning() {

        // mark reconnection as done if we start scanning
        _reconnected = true
        
        if (_scanning) {
            println("skipping scanning due to already scanning")
            return
        }
        
        _scanning = true
        if (isEnabled(.BluetoothLE)) {
            BluetoothLEDeviceManager.sharedInstance.startScanning()
        }
        
        if (isEnabled(.Wifi)) {
            WifiDeviceManager.sharedInstance.startScanning()
        }
    }
    
    ///
    /// Stop scanning for devices
    ///
    public func stopScanning() {

        if (isEnabled(.BluetoothLE)) {
            BluetoothLEDeviceManager.sharedInstance.stopScanning()
        }

        if (isEnabled(.Wifi)) {
            WifiDeviceManager.sharedInstance.stopScanning()
        }
        _scanning = false
    }
    
    ///
    /// Check if we are actively scanning
    ///
    /// :returns:
    ///     If we are scanning
    ///
    public var scanning : Bool {
        get {
            return _scanning
        }
    }
    
    // RENAME/REMOVE DEVICES

    ///
    /// Set an alias on a device.  An alias allows a user to locally override the name of a device without actually changing the
    /// name of the device
    ///
    /// :param: device
    ///     The device to alias
    /// :param: deviceAlias
    ///     The alias to use (null to remove aliases)
    ///
    public func setDeviceAlias(device: Device, deviceAlias: String?) {
        
        // DO NOT REMOVE THIS - NEEDED FOR iOS 8 bug
        // http://stackoverflow.com/questions/26809986/exc-bad-access-on-ios-8-1-with-dictionary
        let stupidHack = self._deviceAliases
        
        if (deviceAlias == nil) {
            _deviceAliases.removeValueForKey(device.deviceId)
        }
        else {
            _deviceAliases[device.deviceId] = deviceAlias
        }
        device.deviceAlias = deviceAlias
        _saveSettings()
    }
    
    ///
    /// Retrieve the stored value for the secure code that is used to secure this device connection.
    ///
    /// :param: device
    ///     The device the secure code is for
    /// :returns:
    ///     The secure code
    ///
    public func retrieveDeviceSecureCode(device: Device) -> String? {
        return _deviceSecureCodes[device.deviceId]
    }
    
    ///
    /// Store the secure code to use when attempting to secure the device connection.  This way we
    /// don't have to prompt the user for it every time.
    ///
    /// :param: device
    ///     The device the secure code is for
    /// :param: secureCode
    ///     The secure code
    ///
    public func storeDeviceSecureCode(device: Device, secureCode: String?) {
        
        // DO NOT REMOVE THIS - NEEDED FOR iOS 8 bug
        // http://stackoverflow.com/questions/26809986/exc-bad-access-on-ios-8-1-with-dictionary
        let stupidHack = self._deviceSecureCodes
        
        if (secureCode == nil) {
            _deviceSecureCodes.removeValueForKey(device.deviceId)
        }
        else {
            _deviceSecureCodes[device.deviceId] = secureCode
        }
        _saveSettings()
    }
    
    ///
    /// Remove a device from the history
    ///
    /// :param: device
    ///     the device to remove
    ///
    public func forgetDevice(device: Device) {
        
        if (isEnabled(.BluetoothLE)) {
            if (BluetoothLEDeviceManager.sharedInstance.hasDevice(device.deviceId)) {
                BluetoothLEDeviceManager.sharedInstance.forgetDevice(device.deviceId)
            }
        }

        if (isEnabled(.Wifi)) {
            if (WifiDeviceManager.sharedInstance.hasDevice(device.deviceId)) {
                WifiDeviceManager.sharedInstance.forgetDevice(device.deviceId)
            }
        }
        
        // DO NOT REMOVE THIS - NEEDED FOR iOS 8 bug
        // http://stackoverflow.com/questions/26809986/exc-bad-access-on-ios-8-1-with-dictionary
        let stupidHack = self._deviceAliases
        let stupidHack2 = self._deviceSecureCodes

        _deviceAliases.removeValueForKey(device.deviceId)
        _deviceSecureCodes.removeValueForKey(device.deviceId)
        _saveSettings()
    }

    // LIST DEVICES
    
    ///
    /// Retrieve a specific device
    ///
    /// :param: deviceId
    ///     the id of the device to retrieve
    /// :returns:
    ///     the device or null if not found
    ///
    public func deviceForId(deviceId: String) -> Device? {

        if (isEnabled(.BluetoothLE)) {
            if (BluetoothLEDeviceManager.sharedInstance.hasDevice(deviceId)) {
                return _flushOut(BluetoothLEDeviceManager.sharedInstance.deviceForId(deviceId))
            }
        }
        
        if (isEnabled(.Wifi)) {
            if (WifiDeviceManager.sharedInstance.hasDevice(deviceId)) {
                return _flushOut(WifiDeviceManager.sharedInstance.deviceForId(deviceId))
            }
        }
        
        return nil
    }
    
    ///
    /// Retrieve all devices. Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service id to filter
    /// :returns:
    ///     The devices that match the filter
    ///
    public func devices(serviceId: String?) -> Array<Device> {
        
        var result =  Array<Device>()
        if (isEnabled(.BluetoothLE)) {
            result += BluetoothLEDeviceManager.sharedInstance.devices(serviceId)
        }
        
        if (isEnabled(.Wifi)) {
            result += WifiDeviceManager.sharedInstance.devices(serviceId)
        }
        return _filterDevices(result, connected:nil, inRange: nil, active: nil)
    }
    
    ///
    /// Retrieve all the devices that are connected.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service id to filter
    /// :returns:
    ///     the devices that are connected and match the filter
    ///
    public func connectedDevices(serviceId: String?) -> Array<Device> {
        var result =  Array<Device>()
        if (isEnabled(.BluetoothLE)) {
            result += BluetoothLEDeviceManager.sharedInstance.devices(serviceId)
        }
        
        if (isEnabled(.Wifi)) {
            result += WifiDeviceManager.sharedInstance.devicesOutOfRange(serviceId)
        }
        return _filterDevices(result, connected: true, inRange: nil, active: nil)
    }

    ///
    /// Retrieve all active devices.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service id to filter
    /// :returns:
    ///     the devices that are active and match the filter
    ///
    public func activeDevices(serviceId: String?) -> Array<Device> {
        
        var result =  Array<Device>()
        if (isEnabled(.BluetoothLE)) {
            result += BluetoothLEDeviceManager.sharedInstance.devices(serviceId)
        }
        
        if (isEnabled(.Wifi)) {
            result += WifiDeviceManager.sharedInstance.devicesInRange(serviceId)
            result += WifiDeviceManager.sharedInstance.devicesOutOfRange(serviceId)
        }
        return _filterDevices(result, connected: nil, inRange: nil, active: true)
    }

    ///
    /// Retrieve all inactive devices.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service id to filter
    /// :returns:
    ///     the devices that are inactive and match the filter
    ///
    public func inactiveDevices(serviceId: String?) -> Array<Device> {

        var result =  Array<Device>()
        if (isEnabled(.BluetoothLE)) {
            result += BluetoothLEDeviceManager.sharedInstance.devices(serviceId)
        }
        
        if (isEnabled(.Wifi)) {
            result += WifiDeviceManager.sharedInstance.devicesInRange(serviceId)
        }
        return _filterDevices(result, connected: nil, inRange: true, active: false)
    }

    ///
    /// Retrieve all out of range devices.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service id to filter
    /// :returns:
    ///     the devices that are out of range and match the filter
    ///
    public func outOfRangeDevices(serviceId: String?) -> Array<Device> {
        var result =  Array<Device>()
        if (isEnabled(.BluetoothLE)) {
            result += BluetoothLEDeviceManager.sharedInstance.devices(serviceId)
        }
        
        if (isEnabled(.Wifi)) {
            result += WifiDeviceManager.sharedInstance.devicesOutOfRange(serviceId)
        }
        return _filterDevices(result, connected: nil, inRange: false, active: false)
    }

    // ACTIVATE AND CONNECT TO DEVICES

    ///
    /// Make a device active and connect to it.  This will allow you to automatically reconnect to the device
    /// using the reconnect() method.
    ///
    /// :param: device
    ///     the device to make active
    /// :param: deactivateOthers
    ///     if we should deactivate (and possibly disconnect) from all other devices
    ///
    public func activateDevice(device: Device, deactivateOthers: Bool) {

        if (deactivateOthers) {
            for deviceId in _activeDeviceIds {
                var oldDevice = deviceForId(deviceId)
                if (oldDevice != nil) {
                    deactivateDevice(oldDevice!)
                }
            }

            _activeDeviceIds.removeAll(keepCapacity: true)
        }

        _activeDeviceIds.append(device.deviceId)
        _saveSettings()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if (self._delegate != nil) {
                self._delegate!.deviceManager(self, deviceDidActivate: device)
            }
            
        }

        self._connect(device)        
    }

    ///
    /// Make a device inactive and disconnect from it.  This will remove the device from the list of devices to
    /// automatically reconnect to using the reconnect() method.
    ///
    /// :param: device
    ///     the device to make inactive
    ///
    public func deactivateDevice(device: Device) {
        var i = 0
        for s in _activeDeviceIds {
            if (s == device.deviceId) {
                _activeDeviceIds.removeAtIndex(i)
                break
            }
            i++
        }
        
        self._disconnect(device)
        
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidDeactivate: device)
        }

        _saveSettings()
    }
    
    ///
    /// Connect to a device
    ///
    /// :param: device
    ///     the device to connect to
    ///
    public func connectDevice(device : Device) {
        self._connect(device)
    }
    
    ///
    /// Disconnect from a device
    ///
    /// :param: device
    ///     the device to disconnect from
    ///
    public func disconnectDevice(device : Device) {
        self._disconnect(device)
    }
    
    ///
    /// Check if a device is marked as active
    ///
    /// :param: device
    ///     the device to check for active
    ///
    /// :returns:
    ///     if the device is active
    ///
    public func isActive(device: Device) -> Bool {
        var active = false
        for s in _activeDeviceIds {
            if device.deviceId == s {
                active = true
                break
            }
        }
        
        // override
        for s in _transientInactiveDeviceIds {
            if device.deviceId == s {
                active = false
                break
            }
        }
        
        return active
    }
    

    
    ///
    /// Check if we have any active devices.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service to filter
    ///
    /// :returns:
    ///     if we have active devices
    ///
    public func hasActiveDevices(serviceId: String?) -> Bool {
        return activeDevices(serviceId).count > 0
    }
    
    ///
    /// Check if we have any connected devices.  Optionally filter by service id.
    ///
    /// :param: serviceId
    ///     the service to filter
    ///
    /// :returns:
    ///     if we have connected devices
    ///
    public func hasConnectedDevices(serviceId: String?) -> Bool {
        for device in devices(serviceId) {
            if (device.connected) {
                return true
            }
        }
        return false
    }

    
    private func _disconnect(device: Device) {

        var exists = false
        var i = 0
        for s in _transientInactiveDeviceIds {
            if (s == device.deviceId) {
                exists = true
            }
            i++
        }
        
        if (!exists) {
            _transientInactiveDeviceIds.append(device.deviceId)
        }
        
        device.disconnect()
    }

    private func _connect(device: Device) {

        var i = 0
        for s in _transientInactiveDeviceIds {
            if (s == device.deviceId) {
                _transientInactiveDeviceIds.removeAtIndex(i)
                break
            }
            i++
        }

        device.connect()

//        if (self._delegate != nil) {
//            self._delegate!.deviceManager(self, deviceDidConnect:device)
//        }
    }
    
    
    private func _flushOut(device: Device?) -> Device? {

        if (device == nil) {
            return nil
        }
        
        var deviceAlias = _deviceAliases[device!.deviceId]
        if (deviceAlias != nil) {
            device!.deviceAlias = deviceAlias!
        }
        
        return device!
    }

    
    private func _filterDevices(devices: Array<Device>, connected: Bool?, inRange: Bool?, active : Bool?) -> Array<Device> {
        var result =  Array<Device>()
        for device in devices {
            var d = _flushOut(device)
            if (d != nil) {
                var match = true
                if (connected != nil) {
                    var r = d!.connected
                    if ((!r && connected!) || (r && !connected!)) {
                        match = false
                    }
                }
                if (inRange != nil) {
                    var r = d!.inRange
                    if ((!r && inRange!) || (r && !inRange!)) {
                        match = false
                    }
                }
                if (active != nil) {
                    var a = isActive(d!)
                    if ((!a && active!) || (a && !active!)) {
                        match = false
                    }
                }
                
                if (match) {
                    result.append(d!)
                }
            }
        }
        
        return result
    }

    
    private func _loadSettings() {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        
        if let data = NSKeyedUnarchiver.unarchiveObjectWithFile("\(documentsPath)/_device_aliases") as? Dictionary<String, String> {
            _deviceAliases = data
        }

        if let data = NSKeyedUnarchiver.unarchiveObjectWithFile("\(documentsPath)/_device_secure") as? Dictionary<String, String> {
            _deviceSecureCodes = data
        }

        if let data = NSKeyedUnarchiver.unarchiveObjectWithFile("\(documentsPath)/_active_device_ids") as? Array<String> {
            _activeDeviceIds = data
        }
    }
    
    private func _saveSettings() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        NSKeyedArchiver.archiveRootObject(_deviceAliases, toFile: "\(documentsPath)/_device_aliases")
        NSKeyedArchiver.archiveRootObject(_deviceSecureCodes, toFile: "\(documentsPath)/_device_secure")
        NSKeyedArchiver.archiveRootObject(_activeDeviceIds, toFile: "\(documentsPath)/_active_device_ids")
    }

    
    private func _checkForFinishedReconnecting(device: Device) {
        if (_reconnectingDevices[device.deviceId] != nil) {
            _reconnectingDevices.removeValueForKey(device.deviceId)
            
            if (_reconnectingDevices.count == 0) {
                if (self._delegate != nil) {
                    self._delegate!.deviceManagerDidFinishReconnectingDevices(self)
                }
            }
        }
    }
    
    private func _checkForFinishedDisconnecting(device: Device) {
        if (_disconnectingDevices[device.deviceId] != nil) {
            _disconnectingDevices.removeValueForKey(device.deviceId)
            
            if (_disconnectingDevices.count == 0) {
                if (self._delegate != nil) {
                    self._delegate!.deviceManagerDidFinishDisconnectingDevices(self)
                }
            }
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidMoveOutOfRange device: BluetoothLEDevice)
    {
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidMoveOutOfRange: device)
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidMoveInRange device: BluetoothLEDevice)
    {
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidMoveInRange: device)
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidConnect device: BluetoothLEDevice)
    {
        _checkForFinishedReconnecting(device)
        
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidConnect: device)
        }
    }

    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidFailToConnect device: BluetoothLEDevice)
    {
        _checkForFinishedReconnecting(device)
        
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidFailToConnect: device)
        }
    }

    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidDisconnect device: BluetoothLEDevice)
    {
        _checkForFinishedDisconnecting(device)

        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidDisconnect:device)
        }
    }
    
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: WifiDeviceManager, deviceDidMoveOutOfRange device: WifiDevice)
    {
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidMoveOutOfRange: device)
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: WifiDeviceManager, deviceDidMoveInRange device: WifiDevice)
    {
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidMoveInRange: device)
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: WifiDeviceManager, deviceDidConnect device: WifiDevice)
    {
        _checkForFinishedReconnecting(device)

        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidConnect: device)
        }
    }
    
    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: WifiDeviceManager, deviceDidFailToConnect device: WifiDevice)
    {
        _checkForFinishedReconnecting(device)
        
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidFailToConnect: device)
        }
    }

    ///
    /// Internal method
    /// :param: manager
    /// :param: device
    ///
    func deviceManager(manager: WifiDeviceManager, deviceDidDisconnect device: WifiDevice)
    {
        _checkForFinishedDisconnecting(device)
     
        if (self._delegate != nil) {
            self._delegate!.deviceManager(self, deviceDidDisconnect:device)
        }
    }

    
}
