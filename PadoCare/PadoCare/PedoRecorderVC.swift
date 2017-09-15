//
//  ViewController.swift
//  PadoCare
//
//  Created by SunilMaurya on 14/09/17.
//  Copyright © 2017 SunilMaurya. All rights reserved.
//

import UIKit


class PedoRecorderVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var pedoInformationView: UIView!
    
    //variables
    var totalDistance:Double?
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Helper method
    fileprivate func initializeViews() {
        self.pedoInformationView.isHidden = true
        self.startStopButton.layer.cornerRadius = 4.0
        self.activityView.isHidden = true
        self.saveButton.isHidden = true
    }

    //MARK:- Action method
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        if let title = buttonTitle {
            if title == "" {//fetching steps count
                return
            }
            if title == "Start" {//start
                self.startStopButton.setTitle("", for: .normal)
                PedoMeterManager.sharedInstance.delegate = self
                PedoMeterManager.sharedInstance.start()
                self.activityView.isHidden = false
                self.saveButton.isHidden = true
                self.welcomeLabel.textColor = UIColor.black
                self.welcomeLabel.text = "Walk over to see footprint count!!!"
            } else {//stop
                PedoMeterManager.sharedInstance.stop()
                DispatchQueue.main.async {
                    self.pedoInformationView.isHidden = true
                    self.startStopButton.setTitle("Start", for: .normal)
                    self.welcomeLabel.textColor = UIColor.black
                    self.welcomeLabel.text = "Welcome!!!"
                    if self.totalDistance != nil {
                        self.saveButton.isHidden = false
                    }
                }
            }
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let distanceCovered = self.totalDistance {
            self.saveButton.isHidden = true
            HealthManager.sharedInstance.delegate = self
            HealthManager.sharedInstance.saveInfo(distance: distanceCovered)
            self.startStopButton.isHidden = true
            self.pedoInformationView.isHidden = true
            self.welcomeLabel.text = "Saving..."
        }
    }
}

//MARK:- PedoMeterManager Delegate
extension PedoRecorderVC:PedoMeterManagerProtocol {
    func didReceivedPedoInfo(padoInfo: [String : NSNumber?]) {
        if let stepsValue = padoInfo["steps"], let distanceValue = padoInfo["distance"] {
            self.totalDistance = distanceValue?.doubleValue
            DispatchQueue.main.async {
                if self.startStopButton.title(for: .normal) == "" {
                    self.activityView.isHidden = true
                    self.startStopButton.setTitle("Stop", for: .normal)
                }
                self.pedoInformationView.isHidden = false
                self.stepsLabel.text = PedoRecorderInteractor.getFormatedStringFromNumber(number: stepsValue)
                self.distanceLabel.text = PedoRecorderInteractor.getFormatedStringFromNumber(number: distanceValue)
            }
            
        }
    }
    func didFailToReceivePedoInfo(errorMsg: String) {
        DispatchQueue.main.async {
            self.activityView.isHidden = true
            self.startStopButton.isHidden = true
            self.pedoInformationView.isHidden = true
            self.welcomeLabel.textColor = UIColor.red
            self.welcomeLabel.text = errorMsg
        }
    }
}

//MARK:- HealthManager Delegate
extension PedoRecorderVC:HealthManagerProtocol {
    func didReceivedSaveSuccess() {
        self.startStopButton.isHidden = false
        self.welcomeLabel.textColor = UIColor.green
        self.welcomeLabel.text = "Save Successful!!!\nYou can start with new measurement"
    }
    func didFailToSave(errorMsg: String) {
        self.welcomeLabel.textColor = UIColor.red
        self.welcomeLabel.text = errorMsg
        self.startStopButton.isHidden = false
    }
}

