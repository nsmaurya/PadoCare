//
//  PedoMeterManager.swift
//  PadoCare
//
//  Created by SunilMaurya on 14/09/17.
//  Copyright © 2017 SunilMaurya. All rights reserved.
//

import Foundation
import CoreMotion

protocol PedoMeterManagerProtocol: class {
    func didReceivedPedoInfo(padoInfo:[String:NSNumber?])
    func didFailToReceivePedoInfo(errorMsg:String)
}

private let _sharedInstance = PedoMeterManager()
class PedoMeterManager:NSObject {
    //variables
    weak var delegate:PedoMeterManagerProtocol?
    fileprivate let pedoMeter:CMPedometer
    var pedoStartDate:Date?
    var pedoEndDate:Date?
    
    //shared instance
    class var sharedInstance:PedoMeterManager {
        return _sharedInstance
    }
    
    //initialization
    fileprivate override init() {
        pedoMeter = CMPedometer()
        delegate = nil
        super.init()
    }
    
    //MARK:- Start Pedometer
    func start() {
        self.pedoStartDate = Date()
        self.pedoMeter.startUpdates(from: self.pedoStartDate!) { (pedoInfo, error) in
            if error == nil {
                var dictPedoInfo = [String:NSNumber?]()
                if CMPedometer.isStepCountingAvailable() {
                    dictPedoInfo["steps"] = pedoInfo?.numberOfSteps
                }
                if CMPedometer.isDistanceAvailable() {
                    dictPedoInfo["distance"] = pedoInfo?.distance
                }
                self.delegate?.didReceivedPedoInfo(padoInfo: dictPedoInfo)
            } else {
                self.delegate?.didFailToReceivePedoInfo(errorMsg: error?.localizedDescription ?? "Unable to activate padometer")
            }
        }
    }
    
    //MARK:- Stop Pedometer
    func stop() {
        self.pedoMeter.stopUpdates()
        self.pedoEndDate = Date()
    }
}
