//
//  PedoRecorderInteractor.swift
//  PadoCare
//
//  Created by SunilMaurya on 14/09/17.
//  Copyright © 2017 SunilMaurya. All rights reserved.
//

import Foundation

class PedoRecorderInteractor {
    class func getFormatedStringFromNumber(number:NSNumber?, withFractionDigit:Int) -> String {
        if let numberValue = number {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = withFractionDigit
            return formatter.string(from: numberValue) ?? "0"
        } else {
            return "0"
        }
    }
}
