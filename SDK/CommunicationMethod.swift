//
//  CommunicationMethod.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The communication methods supported by the device manager
public enum CommunicationMethod : Int
{
    /// Wireless internet
    case Wifi = 0,
    /// Classic Bluetooth
    Bluetooth = 1,
    /// Bluetooth Low Energy
    BluetoothLE = 2
}