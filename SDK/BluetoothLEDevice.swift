//
//  BluetoothLEDevice.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothLEDevice : Device, CBPeripheralDelegate {
    
    class func create(deviceId: String, deviceName: String, deviceAlias : String?, manufacturerName: String, modelName: String, peripheral: CBPeripheral) ->  BluetoothLEDevice {
        return BluetoothLEDevice(deviceId: deviceId, deviceName: deviceName, deviceAlias: deviceAlias, manufacturerName: manufacturerName, modelName: modelName, peripheral: peripheral)
    }
    
    private var _peripheral : CBPeripheral?
    private var _services : Dictionary<String, BluetoothLEService> = Dictionary<String, BluetoothLEService>()
    private var _inRange : Bool = false

    init(deviceId: String, deviceName: String, deviceAlias : String?, manufacturerName: String, modelName: String, peripheral: CBPeripheral) {
        super.init(deviceId: deviceId, deviceName: deviceName, deviceAlias: deviceAlias, manufacturerName: manufacturerName, modelName: modelName)
        
        _peripheral = peripheral
        _peripheral!.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var communicationMethod : CommunicationMethod {
        get {
            return CommunicationMethod.BluetoothLE
        }
    }
    
    override func getService(serviceId : String) -> Service {
        return _services[serviceId]! as! Service
    }
    
    var peripheral : CBPeripheral? {
        get {
            return _peripheral
        }
        set {
            _peripheral = newValue
            _peripheral!.delegate = self
        }
    }
    
    override func connect() {
        

        if (deviceState == .Disconnected || deviceState == .OutOfRange) {
            println("Connect to \(deviceId)")

            deviceState = .Connecting
            BluetoothLEDeviceManager.sharedInstance.connect(self)

            if (hasService(TIMER_SERVICE_ID)) {
                let secureCode = CentralDeviceManager.sharedInstance.retrieveDeviceSecureCode(self)
                _services[TIMER_SERVICE_ID] = BluetoothLETimerService(secureCode: secureCode, peripheral: _peripheral!)
            }
            else if (hasService(HEART_RATE_SERVICE_ID)) {
                _services[HEART_RATE_SERVICE_ID] = BluetoothLEHeartRateService(peripheral: _peripheral!)
            }
        }
    }
    
    override func didConnect()
    {
        if (deviceState == .Connecting) {
            deviceState = .Connected
            _inRange = true

            println("Did Connect")
            
            var serviceUUIDs : [CBUUID] = []
            for service in _services.values {
                serviceUUIDs.append(service.serviceUUID)
            }
            _peripheral!.discoverServices(serviceUUIDs)
        }
    }
    
    override func disconnect() {
        println("Disconnect")

        if (deviceState == .Connecting || deviceState == .Connected) {
            BluetoothLEDeviceManager.sharedInstance.disconnect(self)
        }
    }
    
    override func didDisconnect() {

        println("Did Disconnect")
        if (_inRange) {
            deviceState = .Disconnected
        }
        else {
            deviceState = .OutOfRange
        }
    }

    override func didFailToConnect() {
        
        println("Did Fail To Connect")
        if (_inRange) {
            deviceState = .Disconnected
        }
        else {
            deviceState = .OutOfRange
        }
    }
    
    override func didMoveIntoRange() {
        println("Did Move Into Range")
        if (deviceState == .OutOfRange) {
            deviceState = .Disconnected
        }
        _inRange = true
    }
    
    override func didMoveOutOfRange() {
        println("Did Move Out Of Range")
        deviceState = .OutOfRange
        _inRange = false
    }

    
    func peripheral(peripheral: CBPeripheral!,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!)
    {
        println("Did Update value for characteristic")
        
        let sendingInitialCommunicationBefore = _services[serviceIds[0]]!.sendingInitialCommunication
        
        // assumes only one service
        _services[serviceIds[0]]!.didUpdateValueForCharacteristic(characteristic)
 
        let sendingInitialCommunicationAfter = _services[serviceIds[0]]!.sendingInitialCommunication

        if (sendingInitialCommunicationBefore && !sendingInitialCommunicationAfter && self.delegate != nil) {
            self.delegate!.establishedCommunicationChannel(self)
        }
        
        if (self.delegate != nil) {
            self.delegate!.receivedDataFromDevice(self)
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!,
        didUpdateValueForDescriptor descriptor: CBDescriptor!,
        error: NSError!)
    {
        // assumes only one service
        _services[serviceIds[0]]!.didUpdateValueForDescriptor(descriptor)
        
        if (self.delegate != nil) {
            self.delegate!.receivedDataFromDevice(self)
        }
        
    }

    func peripheral(peripheral: CBPeripheral!,
        didWriteValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!)
    {
        println("Did Write value for characteristic")

        // assumes only one service
        _services[serviceIds[0]]!.didWriteValueForCharacteristic(characteristic)

        if (self.delegate != nil) {
            self.delegate!.sentDataToDevice(self)
        }
    }

    
    func peripheral(peripheral: CBPeripheral!,
        didWriteValueForDescriptor descriptor: CBDescriptor!,
        error: NSError!)
    {
        println("Did Write value for descriptor")

        // assumes only one service
        _services[serviceIds[0]]!.didWriteValueForDescriptor(descriptor)
        
        if (self.delegate != nil) {
            self.delegate!.sentDataToDevice(self)
        }
    }

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("Did Discover Services For \(peripheral.identifier)")

        if (peripheral.services != nil && peripheral.services.count > 0) {
            // assumes only one service
            let service = peripheral.services[0] as! CBService
            _services[serviceIds[0]]!.didDiscoverService(service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {

        println("Did Discover Characteristics")

        // assumes only one service
        _services[serviceIds[0]]!.didDiscoverCharacteristicsForService(service)
 
    }

 
}