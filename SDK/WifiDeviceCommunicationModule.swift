//
//  WifiDeviceController.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

class WifiDeviceCommunicationModule {
    
    private let BUFFER_SIZE = 128
    
    private var _client : TCPClient?
    private var _device : WifiDevice
    private var _connected : Bool = false
    
    // Constructor
    init(device: WifiDevice) {
        _device = device
    }
    
    var connected  : Bool {
        get {
            return _client != nil && _connected
        }
    }
    
    func connect() -> Bool {
        return _connect()
    }
    
    func disconnect() {
        _disconnect()
    }
    
    func sendCommand(command: String) -> (responseCode: ResponseCode, result: Array<UInt8>?) {

        if (!connected) {
            println("Not Connected!")
            return (ResponseCode.NoConnection, nil)
        }
    
        var (success,errmsg) = _client!.send(str: command)

        if (!success) {
            return (ResponseCode.CommunicationFailed, nil)
        }
        
        var data : [UInt8]? = _client!.read(BUFFER_SIZE)
        
        return (ResponseCode.Success, data)
    }
    
    private func _connect() -> Bool {
        println("Wifi Connect to \(_device.ipAddress)")

        if (_client == nil) {
            _client = TCPClient(addr: _device.ipAddress, port: _device.port)
        }

        if (!_connected) {
            var (success, errmsg) = _client!.connect(timeout: 5)
            println("Wifi Connection: \(success) [Error: \(errmsg)]")
            if (success) {
                _connected = true
            }
        }

        return _connected
    }
    
    private func _disconnect() {
        println("Wifi Disconnect!")

        if (_client != nil) {
            _client!.close()
            _client = nil
            _connected = false
        }
    }
    
}