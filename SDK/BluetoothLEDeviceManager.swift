//
//  BluetoothLEDeviceManager.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothLEDeviceManagerDelegate {
    
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidMoveInRange device: BluetoothLEDevice)
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidMoveOutOfRange device: BluetoothLEDevice)

    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidConnect device: BluetoothLEDevice)
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidFailToConnect device: BluetoothLEDevice)
    func deviceManager(manager: BluetoothLEDeviceManager, deviceDidDisconnect device: BluetoothLEDevice)
}

class BluetoothLEDeviceManager : NSObject, DeviceManager, CBCentralManagerDelegate {
    
    private let CONNECTION_TIMEOUT = 5.0
    
    private var _delegate : BluetoothLEDeviceManagerDelegate?

    private var _scanning : Bool = false
    private var _devices : Dictionary<String, BluetoothLEDevice> = Dictionary<String, BluetoothLEDevice>()
    
    private var _cm : CBCentralManager?
    private let _cbcmQueue = dispatch_queue_create("com.adafruit.bluefruitconnect.cbcmqueue", DISPATCH_QUEUE_CONCURRENT)
    
    private var _connectionTimeoutTimers : Dictionary<String, NSTimer> = Dictionary<String, NSTimer>()

    
    class var sharedInstance : BluetoothLEDeviceManager {
        struct Static {
            static let instance : BluetoothLEDeviceManager = BluetoothLEDeviceManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        _cm = CBCentralManager(delegate: self, queue: _cbcmQueue)
        _loadDevices()
    }
    
    
    var delegate : BluetoothLEDeviceManagerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }
    
    var available : Bool {
        get {
            return _cm!.state == CBCentralManagerState.PoweredOn
        }
    }
    
    var scanning : Bool {
        get {
            return _scanning
        }
    }
    
    var cbCentralManager : CBCentralManager {
        get {
            return _cm!
        }
    }
    
    func startScanning() -> Bool {
        if (!available) {
            return false
        }
        
        _scanning = true

        // TODO: Support GymNext Profile only
        _cm!.scanForPeripheralsWithServices(nil, options: nil)
        
        return true
    }
    
    func stopScanning() {
        if (!available) {
            return
        }

        _cm!.stopScan()
        _scanning = false
    }
    
    
    func hasDevice(deviceId: String) -> Bool {
        return _devices[deviceId] != nil
    }
    
    func forgetDevice(deviceId: String) {
        // DO NOT REMOVE THIS - NEEDED FOR iOS 8 bug
        // http://stackoverflow.com/questions/26809986/exc-bad-access-on-ios-8-1-with-dictionary
        let stupidHack = self._devices

        _devices.removeValueForKey(deviceId)
        _saveDevices()
    }

    func deviceForId(deviceId: String) -> Device? {
        if (_devices[deviceId] != nil) {
            return _devices[deviceId]
        }
//        else if (_outOfRangeDevices[deviceId] != nil) {
//            return _outOfRangeDevices[deviceId]
//        }
        return nil
    }
    
    func devices(serviceId: String?) -> Array<Device> {
        var result = Array<Device>()
        for device in _devices.values {
            if (serviceId == nil || device.hasService(serviceId!)) {
                result.append(device)
            }
        }
//        for device in _outOfRangeDevices.values {
//            if (serviceId == nil || device.hasService(serviceId!)) {
//                result.append(device)
//            }
//        }
        return result
    }
    
//    func devicesInRange(serviceId: String?) -> Array<Device> {
//        var result = Array<Device>()
//        for device in _inRangeDevices.values {
//            if (serviceId == nil || device.hasService(serviceId!)) {
//                result.append(device)
//            }
//        }
//        return result
//    }
//    
//    func devicesOutOfRange(serviceId: String?) -> Array<Device> {
//        var result = Array<Device>()
//        for device in _outOfRangeDevices.values {
//            if (serviceId == nil || device.hasService(serviceId!)) {
//                result.append(device)
//            }
//        }
//        return result
//    }
    
    func connect(device: BluetoothLEDevice) {
        println("Connect to BTLE \(device.deviceId)")
        BluetoothLEDeviceManager.sharedInstance.cbCentralManager.connectPeripheral(device.peripheral!, options: nil)
        _connectionTimeoutTimers[device.deviceId] = NSTimer.scheduledTimerWithTimeInterval(CONNECTION_TIMEOUT, target:self, selector:"connectionTimedOut:", userInfo:device, repeats:false)
    }

    func disconnect(device: BluetoothLEDevice) {
        BluetoothLEDeviceManager.sharedInstance.cbCentralManager.cancelPeripheralConnection(device.peripheral!)
    }
    
    func connectionTimedOut(timer : NSTimer) {
        println("Connection Timeout")
        let device = timer.userInfo! as! BluetoothLEDevice
        device.didFailToConnect()

        if (_delegate != nil) {
            _delegate!.deviceManager(self, deviceDidFailToConnect: device)
        }
    }
    
    private func _loadDevices() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var hasDevices = defaults.objectForKey("bluetoothLEDevicesVersion") != nil
        
        if (hasDevices) {
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            
            if let data = NSKeyedUnarchiver.unarchiveObjectWithFile("\(documentsPath)/__btle_devices") as? Dictionary<String, BluetoothLEDevice> {

                for (deviceId, device) in data {
                    let peripherals = _cm!.retrievePeripheralsWithIdentifiers([CBUUID(string:deviceId)])
                    if (peripherals.count > 0) {
                        device.peripheral = peripherals[0] as? CBPeripheral
                        _devices[deviceId] = device
                    }
                }
                
            }
            
        }
        
    }
    
    private func _saveDevices() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        NSKeyedArchiver.archiveRootObject(_devices, toFile: "\(documentsPath)/__btle_devices")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(1, forKey:"bluetoothLEDevicesVersion")
    }
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let deviceId = peripheral.identifier.UUIDString
        var deviceName = peripheral.name
        
        var acceptableTimer = false
        var acceptableHeartRate = false
        if let serviceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] {
            for serviceUUID in serviceUUIDs {
                
                if (serviceUUID.UUIDString == BluetoothLETimerService.serviceUUID.UUIDString) {
                    println("Acceptable Timer")
                    acceptableTimer = true
                    break
                }
                else if (serviceUUID.UUIDString == BluetoothLEHeartRateService.serviceUUID.UUIDString) {
                    println("Acceptable Heart Rate")
                    acceptableHeartRate = true
                    break
                }
            }
        }
        
        if (advertisementData["kCBAdvDataLocalName"] != nil) {
            deviceName = advertisementData["kCBAdvDataLocalName"] as! String
        }
        
        println("Did discover \(peripheral.identifier) \(peripheral.name) \(deviceName) with \(acceptableTimer) \(acceptableHeartRate) service ids")
        if (acceptableHeartRate || acceptableTimer) {
            
            // TODO: Device Type, ModelName, ServiceId
            var modelName = "Timer2,4"
            var manufacturerName = "GymNext"
            var serviceIds : [String] = [TIMER_SERVICE_ID]
            
            if (acceptableHeartRate) {
                modelName = "Unknown"
                manufacturerName = "Unknown"
                serviceIds = [HEART_RATE_SERVICE_ID]
            }
            
            if (!hasDevice(deviceId)) {
                let device = BluetoothLEDevice.create(deviceId, deviceName: deviceName, deviceAlias: nil, manufacturerName: manufacturerName, modelName: modelName, peripheral: peripheral)
                device.serviceIds = serviceIds
                
                device.didMoveIntoRange()
                _devices[device.deviceId] = device
                _saveDevices()

                if (_delegate != nil) {
                    _delegate!.deviceManager(self, deviceDidMoveInRange: device)
                }
            }
            else {
                let device = deviceForId(deviceId) as! BluetoothLEDevice!
                
                if (device.deviceName != deviceName) {
                    device.deviceName = deviceName
                    _saveDevices()

                    if (_delegate != nil) {
                        // Trigger an update
                        _delegate!.deviceManager(self, deviceDidMoveInRange: device)
                    }
                }

                
                if (device.deviceState == .OutOfRange) {
                    device.didMoveIntoRange()

                    if (_delegate != nil) {
                        _delegate!.deviceManager(self, deviceDidMoveInRange: device)
                    }
                }
            }
        }
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        // does nothing
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Device Id \(peripheral.identifier.UUIDString) Connected")

        let deviceId = peripheral.identifier.UUIDString
        if (hasDevice(deviceId)) {
            let device = deviceForId(deviceId) as! BluetoothLEDevice!
            device.didConnect()

            _connectionTimeoutTimers[deviceId]?.invalidate()

            if (_delegate != nil) {
                _delegate!.deviceManager(self, deviceDidConnect: device)
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Device Id \(peripheral.identifier.UUIDString) Failed to connect")
        
        let deviceId = peripheral.identifier.UUIDString
        if (hasDevice(deviceId)) {
            let device = deviceForId(deviceId) as! BluetoothLEDevice!
            device.didFailToConnect()
            
            _connectionTimeoutTimers[deviceId]?.invalidate()

            if (_delegate != nil) {
                _delegate!.deviceManager(self, deviceDidFailToConnect: device)
            }
        }
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {

        println("Device Id \(peripheral.identifier.UUIDString) Disconnected")
        // does nothing
        let deviceId = peripheral.identifier.UUIDString
        if (hasDevice(deviceId)) {
            let device = deviceForId(deviceId) as! BluetoothLEDevice!
            device.didDisconnect()

            _connectionTimeoutTimers[deviceId]?.invalidate()

            if (_delegate != nil) {
                _delegate!.deviceManager(self, deviceDidDisconnect: device)
            }
        }
    }
    
}
