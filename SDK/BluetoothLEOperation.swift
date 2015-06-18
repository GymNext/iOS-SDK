//
//  BluetoothLEOperation.swift
//  SDK
//
//  Created by Duane Homick on 2015-05-25.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc class BluetoothLEOperation {
    
    private var _descriptor : CBDescriptor?
    private var _characteristic : CBCharacteristic?
    private var _value : NSData
    
    init(descriptor : CBDescriptor, value : NSData) {
        _descriptor = descriptor;
        _value = value;
    }
    
    init(characteristic : CBCharacteristic, value : NSData) {
        _characteristic = characteristic;
        _value = value;
    }
    
    var characteristic : CBCharacteristic? {
        get {
            return _characteristic
        }
    }
    
    var descriptor : CBDescriptor? {
        get {
            return _descriptor
        }
    }
    
    var value : NSData {
        get {
            return _value
        }
    }
}