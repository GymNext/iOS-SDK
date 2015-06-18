//
//  DeviceManager.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-02.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

typealias DeviceUpdateCallback = (Device) -> Void

protocol DeviceManager {
    
    var available : Bool { get }

    var scanning : Bool { get }

    func startScanning() -> Bool
    
    func stopScanning()
    
    func hasDevice(deviceId: String) -> Bool

    func deviceForId(deviceId: String) -> Device?
    
    func devices(serviceId: String?) -> Array<Device>

//    func devicesInRange(serviceId: String?) -> Array<Device>
//
//    func devicesOutOfRange(serviceId: String?) -> Array<Device>

    func forgetDevice(deviceId: String)
}