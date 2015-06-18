//
//  WifiDeviceManager.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-01.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

protocol WifiDeviceManagerDelegate {
    
    func deviceManager(manager: WifiDeviceManager, deviceDidMoveInRange device: WifiDevice)
    func deviceManager(manager: WifiDeviceManager, deviceDidMoveOutOfRange device: WifiDevice)

    func deviceManager(manager: WifiDeviceManager, deviceDidConnect device: WifiDevice)
    func deviceManager(manager: WifiDeviceManager, deviceDidFailToConnect device: WifiDevice)
    func deviceManager(manager: WifiDeviceManager, deviceDidDisconnect device: WifiDevice)
}

class WifiDeviceManager : DeviceManager {
    
    private var _delegate : WifiDeviceManagerDelegate?

    private var _scanning : Bool = false
    private var _inRangeDevices : Dictionary<String, WifiDevice>
    private var _outOfRangeDevices : Dictionary<String, WifiDevice>
    
    class var sharedInstance : WifiDeviceManager {
        struct Static {
            static let instance : WifiDeviceManager = WifiDeviceManager()
        }
        return Static.instance
    }
    
    init() {
        _inRangeDevices = Dictionary<String, WifiDevice>()
        _outOfRangeDevices = Dictionary<String, WifiDevice>()
        _loadDevices()
    }
    
    var delegate : WifiDeviceManagerDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    var available : Bool {
        get {
            return _getSsid() != nil
        }
    }

    var scanning : Bool {
        get {
            return _scanning
        }
    }
    
    func startScanning() -> Bool {
        
        // No need to restart scanning if we are already scanning
        if (_scanning) {
            return true
        }
        _scanning = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            while (true) {
                self._doWifiDiscovery();
                
//                if (!self._scanning) {
//                    break
//                }
//                
//                sleep(15)
//                
//                if (!self._scanning) {
//                    break
//                }
//            }
        }

        return true
    }
    
    func stopScanning() {
        _scanning = false
    }

    
    func hasDevice(deviceId: String) -> Bool {
        return _inRangeDevices[deviceId] != nil || _outOfRangeDevices[deviceId] != nil
    }
    
    func forgetDevice(deviceId: String)  {
        // DO NOT REMOVE THIS - NEEDED FOR iOS 8 bug
        // http://stackoverflow.com/questions/26809986/exc-bad-access-on-ios-8-1-with-dictionary
        let stupidHack = self._outOfRangeDevices

        _outOfRangeDevices.removeValueForKey(deviceId)
        _saveDevices()
    }

    func deviceForId(deviceId: String) -> Device? {
        if (_inRangeDevices[deviceId] != nil) {
            return _inRangeDevices[deviceId]
        }
        else if (_outOfRangeDevices[deviceId] != nil) {
            return _outOfRangeDevices[deviceId]
        }
        return nil
    }
    
    func devices(serviceId: String?) -> Array<Device> {
        var result = Array<Device>()
        for device in _inRangeDevices.values {
            if (serviceId == nil || device.hasService(serviceId!)) {
                result.append(device)
            }
        }
        for device in _outOfRangeDevices.values {
            if (serviceId == nil || device.hasService(serviceId!)) {
                result.append(device)
            }
        }
        return result
    }
    
    func devicesInRange(serviceId: String?) -> Array<Device> {
        var result = Array<Device>()
        for device in _inRangeDevices.values {
            if (serviceId == nil || device.hasService(serviceId!)) {
                result.append(device)
            }
        }
        return result
    }

    func devicesOutOfRange(serviceId: String?) -> Array<Device> {
        var result = Array<Device>()
        for device in _outOfRangeDevices.values {
            if (serviceId == nil || device.hasService(serviceId!)) {
                result.append(device)
            }
        }
        return result
    }

    
    private func _loadDevices() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var hasDevices = defaults.objectForKey("wifiDevicesVersion") != nil
        
        if (hasDevices) {
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
            
            if let data = NSKeyedUnarchiver.unarchiveObjectWithFile("\(documentsPath)/__wifi_devices") as? Dictionary<String, WifiDevice> {
                _outOfRangeDevices = data
            }
        }
    }
    
    private func _saveDevices() {
        
        var allDevices = Dictionary<String, WifiDevice>()
        for device in _inRangeDevices.values {
            allDevices[device.deviceId] = device
        }
        for device in _outOfRangeDevices.values {
            allDevices[device.deviceId] = device
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        NSKeyedArchiver.archiveRootObject(allDevices, toFile: "\(documentsPath)/__wifi_devices")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(1, forKey:"wifiDevicesVersion")
    }
    
    private func _send(url: String) -> NSData? {
        var request = NSURLRequest(URL: NSURL(string: url)!)
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
    }
    
    private func _getSsid() -> String? {
        var dictionary = SsidUtility.fetchSSIDInfo() as! NSDictionary?
        if (UIDevice.currentDevice().model == "iPhone Simulator") {
            return "Homick"
        }
        return dictionary?.objectForKey("SSID") as! String?
    }
    
    private func _encodeParameters(#params: [String: String]) -> String {
        
        if (objc_getClass("NSURLQueryItem") != nil) {
            var queryItems = map(params) { NSURLQueryItem(name:$0, value:$1)}
            var components = NSURLComponents()
            components.queryItems = queryItems
            return components.percentEncodedQuery ?? ""
        }
        else {
            var queryString : String = ""
            for (key, value) in params {
                if let encodedKey = key.URLEncodedString() {
                    if let encodedValue = value.URLEncodedString() {
                        queryString += "&"
                        queryString += encodedKey + "=" + encodedValue
                    }
                }
            }
            return queryString
        }
    }
    
    private func _doWifiDiscovery()
    {
        println("Doing WIFI Discovery....")
        var ssid :String? = self._getSsid()
        
        if (ssid != nil) {
        
            var inRangeDevicesToTest = _inRangeDevices.values
            for device in inRangeDevicesToTest {
                if (!_testConnection(device)) {
                    println("Move device out of range")
                    _moveOutOfRange(device)
                }
            }
            
            var outOfRangeDevicesToTest = _outOfRangeDevices.values
            for device in outOfRangeDevicesToTest {
                if (_testConnection(device)) {
                    println("Move device in range")
                    _moveInRange(device)
                }
            }
            
            var result = _send("http://www.gymnext.com/products/devices/search.json?" + self._encodeParameters(params: ["wlan" : ssid!]))
            
            if (result != nil) {
            
                let json = JSON(data: result!)
                
                let deviceArray = json["devices"].arrayValue
                
                for deviceDict in deviceArray {
                    let deviceId = deviceDict["id"].stringValue
                    let deviceType = deviceDict["device_type"].stringValue
                    let manufacturerName = "GymNext"
                    let modelName = deviceDict["model_name"].stringValue
                    let ipAddress = deviceDict["ip_address"].stringValue
                    let wlan = deviceDict["wlan"].stringValue
                    let macAddress = deviceDict["mac_address"].stringValue
                    
                    if (deviceType == "T") {
                        if (self.hasDevice(deviceId)) {

                            if (self._inRangeDevices[deviceId] != nil) {

                                // In Range Case
                                let device = self._inRangeDevices[deviceId]!

                                if (device.ipAddress != ipAddress) {
                                    
                                    // Change ip address
                                    device.ipAddress = ipAddress
                                    _saveDevices()
                                    
                                    // move out of range
                                    _moveOutOfRange(device)

                                    // retest connection
                                    if (_testConnection(device)) {
                                        _moveInRange(device)
                                    }
                                }
                                
                            }
                            else if (self._outOfRangeDevices[deviceId] != nil) {

                                // Out of Range Case
                                let device = self._outOfRangeDevices[deviceId]!
                                
                                if (device.ipAddress != ipAddress) {
                                    
                                    // Change ip address
                                    device.ipAddress = ipAddress
                                    _saveDevices()
                                    
                                    // retest connection
                                    if (_testConnection(device)) {
                                        _moveInRange(device)
                                    }
                                }
                            }
                        }
                        else {
                            // New device

                            var device = WifiDevice.create(deviceId, deviceName: "GymNext Timer", deviceAlias : nil, manufacturerName: manufacturerName, modelName: modelName, ipAddress: ipAddress, port: 23, macAddress: macAddress)
                            _outOfRangeDevices[deviceId] = device
                            _saveDevices()
                            
                            // Notify of discovery
                            if (_delegate != nil) {
                                _delegate!.deviceManager(self, deviceDidMoveOutOfRange: device)
                            }

                            // Test connection
                            if (_testConnection(device)) {
                                _moveInRange(device)
                            }
                        }
                    }
                    
                }
            }
        }

    }
    

    private func _testConnection(device: WifiDevice) -> Bool {
        return available
    }
    
    private func _moveOutOfRange(device: WifiDevice) {
        _inRangeDevices.removeValueForKey(device.deviceId)
        _outOfRangeDevices[device.deviceId] = device

        if (_delegate != nil) {
            _delegate!.deviceManager(self, deviceDidMoveOutOfRange: device)
        }
    }

    private func _moveInRange(device: WifiDevice) {

        _outOfRangeDevices.removeValueForKey(device.deviceId)
        _inRangeDevices[device.deviceId] = device
        
        if (_delegate != nil) {
            _delegate!.deviceManager(self, deviceDidMoveInRange: device)
        }
    }

}
