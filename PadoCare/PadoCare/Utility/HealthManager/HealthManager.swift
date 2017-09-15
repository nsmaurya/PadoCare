//
//  HealthManager.swift
//  PadoCare
//
//  Created by SunilMaurya on 15/09/17.
//  Copyright © 2017 SunilMaurya. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthManagerProtocol: class {
    func didReceivedSaveSuccess()
    func didFailToSave(errorMsg:String)
}

private let _sharedInstance = HealthManager()
class HealthManager:NSObject {
    //variables
    fileprivate let healthStore:HKHealthStore
    weak var delegate:HealthManagerProtocol?
    
    //shared instance
    class var sharedInstance:HealthManager {
        return _sharedInstance
    }
    
    //initialization
    fileprivate override init() {
        healthStore = HKHealthStore()
        delegate = nil
        super.init()
    }
    
    //MARK:- Save Distance Info
    func saveInfo(distance:Double) {
        let writeTypes: Set<HKSampleType> = Set([HKObjectType.workoutType()])
        self.healthStore.requestAuthorization(toShare: writeTypes, read: nil) { (isSuccess, error) in
            if isSuccess {
                if let pedoStartDate = PedoMeterManager.sharedInstance.pedoStartDate, let pedoEndDate = PedoMeterManager.sharedInstance.pedoEndDate {
                    //total distance covered
                    let totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
                    //creating workout object to save
                    let workout = HKWorkout(activityType: .running, start: pedoStartDate, end: pedoEndDate, workoutEvents: nil, totalEnergyBurned: nil, totalDistance: totalDistance, metadata: nil)
                    //save
                    self.healthStore.save(workout, withCompletion: { (success, exception) in
                        if success {
                            self.delegate?.didReceivedSaveSuccess()
                        } else {
                            self.delegate?.didFailToSave(errorMsg: exception?.localizedDescription ?? "Error in saving data on HealthKit")
                        }
                    })
                }
            } else {
                self.delegate?.didFailToSave(errorMsg: error?.localizedDescription ?? "Error in authorization of HealthKit")
            }
        }
    }
}
