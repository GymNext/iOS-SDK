//
//  BluetoothService.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-06.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothLEService {
    
    var serviceUUID : CBUUID { get }

    var sendingInitialCommunication : Bool { get }
    
    func didDiscoverService(service: CBService!)
    func didDiscoverCharacteristicsForService(service: CBService!)

    func didUpdateValueForCharacteristic(characteristic: CBCharacteristic!)
    func didWriteValueForCharacteristic(characteristic: CBCharacteristic!)

    func didUpdateValueForDescriptor(descriptor: CBDescriptor!)
    func didWriteValueForDescriptor(descriptor: CBDescriptor!)

}