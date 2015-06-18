//
//  ResponseCode.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-06.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

enum ResponseCode : Int {
    case Success = 0,
    NoConnection = 100, // You have not connected to the device yet
    CommunicationFailed = 101, // You may have connected in the past, but the connection has been lost or the communication failed
    DeviceBusy = 200 // The device is not currently accepting commands
}

