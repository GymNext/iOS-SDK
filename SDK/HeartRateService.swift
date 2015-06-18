//
//  HeartRateService.swift
//  SDK
//
//  Created by Duane Homick on 2015-06-08.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

public protocol HeartRateService : Service {

    var heartRate : Int { get }

}
