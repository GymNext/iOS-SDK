//
//  StringExtension.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-09.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

extension String {
    func URLEncodedString() -> String? {
        var customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        var escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString
    }
}