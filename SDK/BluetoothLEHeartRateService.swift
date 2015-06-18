//
//  BluetoothLEHeartRateService.swift
//  SDK
//
//  Created by Duane Homick on 2015-06-08.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothLEHeartRateService : HeartRateService, BluetoothLEService {
    
    // Provided
    private var _deviceName : String
    private var _peripheral : CBPeripheral
    
    // Info
    private var _heartRate : Int = 0

    
    // Internal
    private var _heartRateCharacteristic : CBCharacteristic?
    
    class var serviceUUID : CBUUID {
        get {
            return CBUUID(string: "180D")
        }
    }
    
    class var heartRateCharacteristicUUID : CBUUID {
        get {
            return CBUUID(string: "2A37")
        }
    }
    
    // Constructor
    init(peripheral : CBPeripheral) {
        _peripheral = peripheral
        _deviceName = _peripheral.name
    }
    
    var id : String {
        get {
            return HEART_RATE_SERVICE_ID
        }
    }
    
    var serviceUUID : CBUUID {
        get {
            return BluetoothLEHeartRateService.serviceUUID
        }
    }

    var sendingInitialCommunication : Bool {
        get {
            return false
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //
    // INFORMATION
    //
    ////////////////////////////////////////////////////////////////////////////////////
    
    var heartRate : Int {
        get {
            return _heartRate
        }
    }
    
    func didDiscoverService(service: CBService!) {
        _peripheral.discoverCharacteristics([BluetoothLEHeartRateService.heartRateCharacteristicUUID], forService:service)
    }
    
    func didDiscoverCharacteristicsForService(service: CBService!)
    {
        println("Characteristics for service \(service.characteristics.count)")
        
        for c in (service.characteristics as! [CBCharacteristic]) {
            println("Characteristic is \(c.UUID)")
            switch c.UUID {
            case BluetoothLEHeartRateService.heartRateCharacteristicUUID:
                println("Characteristic is HR \(BluetoothLEHeartRateService.heartRateCharacteristicUUID)")
                _heartRateCharacteristic = c
                _peripheral.setNotifyValue(true, forCharacteristic: _heartRateCharacteristic)
                break
            default:
                break
            }
        }
        
    }
    
    func didUpdateValueForCharacteristic(characteristic: CBCharacteristic!)
    {
        if (characteristic == _heartRateCharacteristic) {

            let dataLength:Int = characteristic.value.length
            var data = [UInt8](count: dataLength, repeatedValue: 0)
            characteristic.value.getBytes(&data, length: dataLength)
            
            var bpm : UInt16 = 0
            
            if (data[0] & 0x01 == 0) {
                
                println("Here")
                bpm = UInt16(data[1])
                
                _heartRate = Int(bpm)
                
            }
            else {
                println("Here2")
            }
            
            println("Heart rate is \(_heartRate)")
        }
    }
    
    func didUpdateValueForDescriptor(descriptor: CBDescriptor!)
    {
        // Ignored
    }
    
    func didWriteValueForCharacteristic(characteristic: CBCharacteristic!)
    {
        // Ignored
    }
    
    func didWriteValueForDescriptor(descriptor: CBDescriptor!)
    {
        // Ignored
    }
        
    
    
    
}
