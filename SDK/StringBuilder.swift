//
//  StringBuilder.swift
//  TimerNext
//
//  Created by Duane Homick on 2015-05-03.
//  Copyright (c) 2015 Duane Homick. All rights reserved.
//

import Foundation

/**
Supports creation of a String from pieces
*/
class StringBuilder {
    private var stringValue: String
    
    /**
    Construct with initial String contents
    
    :param: string Initial value; defaults to empty string
    */
    init(string: String = "") {
        self.stringValue = string
    }
    
    /**
    Return the String object
    
    :returns: String
    */
    func toString() -> String {
        return stringValue
    }
    
    /**
    Return the current length of the String object
    */
    var length: Int {
        return count(stringValue)
    }
    
    /**
    Append a String to the object
    
    :param: string String
    
    :returns: reference to this StringBuilder instance
    */
    func append(string: String) -> StringBuilder {
        stringValue += string
        return self
    }
    
    /**
    Append a Printable to the object
    
    :param: value a value supporting the Printable protocol
    
    :returns: reference to this StringBuilder instance
    */
    func append<T: Printable>(value: T) -> StringBuilder {
        stringValue += value.description
        return self
    }
    
    /**
    Append a String and a newline to the object
    
    :param: string String
    
    :returns: reference to this StringBuilder instance
    */
    func appendLine(string: String) -> StringBuilder {
        stringValue += string + "\n"
        return self
    }
    
    /**
    Append a Printable and a newline to the object
    
    :param: value a value supporting the Printable protocol
    
    :returns: reference to this StringBuilder instance
    */
    func appendLine<T: Printable>(value: T) -> StringBuilder {
        stringValue += value.description + "\n"
        return self
    }
    
    /**
    Reset the object to an empty string
    
    :returns: reference to this StringBuilder instance
    */
    func clear() -> StringBuilder {
        stringValue = ""
        return self
    }
}

/**
Append a String to a StringBuilder using operator syntax

:param: lhs StringBuilder
:param: rhs String
*/
func += (lhs: StringBuilder, rhs: String) {
    lhs.append(rhs)
}

/**
Append a Printable to a StringBuilder using operator syntax

:param: lhs Printable
:param: rhs String
*/
func += <T: Printable>(lhs: StringBuilder, rhs: T) {
    lhs.append(rhs.description)
}

/**
Create a StringBuilder by concatenating the values of two StringBuilders

:param: lhs first StringBuilder
:param: rhs second StringBuilder

:result StringBuilder
*/
func +(lhs: StringBuilder, rhs: StringBuilder) -> StringBuilder {
    return StringBuilder(string: lhs.toString() + rhs.toString())
}