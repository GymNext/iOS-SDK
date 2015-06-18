//
//  SecureMode.swift
//  SDK
//
//  Created by Duane Homick on 2015-05-26.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/// The level of security supported by the devices
public enum SecureMode : Int {

    /// No operations are secured
    case None = 0,
    /// Administrative operations are secured
    Admin,
    /// All operations are secured
    All
    
}
