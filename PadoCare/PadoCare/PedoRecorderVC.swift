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
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var pauseResumeButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var pedoInformationView: UIView!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Helper method
    fileprivate func initializeViews() {
        self.pedoInformationView.isHidden = true
        self.pauseResumeButton.layer.borderColor = UIColor(red: 20.0/255.0, green: 130.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor
        self.pauseResumeButton.layer.borderWidth = 1.0
        self.pauseResumeButton.layer.cornerRadius = 4.0
        self.startStopButton.layer.cornerRadius = 4.0
        self.pauseResumeButton.isHidden = true
        self.activityView.isHidden = true
    }

    //MARK:- Action method
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        if let title = buttonTitle {
            if title == "" {
                return
            }
            if title == "Start" {//start
                self.startStopButton.setTitle("", for: .normal)
                PedoMeterManager.sharedInstance.delegate = self
                PedoMeterManager.sharedInstance.start()
                self.activityView.isHidden = false
                self.welcomeLabel.text = "Walk over to see footprint count!!!"
            } else {//stop
                PedoMeterManager.sharedInstance.stop()
                DispatchQueue.main.async {
                    self.pedoInformationView.isHidden = true
                    self.startStopButton.setTitle("Start", for: .normal)
                    self.pauseResumeButton.isHidden = true
                    self.pauseResumeButton.setTitle("Pause", for: .normal)
                    self.welcomeLabel.textColor = UIColor.black
                    self.welcomeLabel.text = "Welcome!!!"
                }
            }
        }
    }
    
    @IBAction func pauseResumeButtonTapped(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        if let title = buttonTitle {
            var updatedButtonTitle = "Pause"
            if title == "Pause" {//pause
                updatedButtonTitle = "Resume"
            } else {//resume
                
            }
            DispatchQueue.main.async {
                self.pauseResumeButton.setTitle(updatedButtonTitle, for: .normal)
            }
        }
    }
}

extension PedoRecorderVC:PedoMeterManagerProtocol {
    func didReceivedPedoInfo(padoInfo: [String : NSNumber?]) {
        if let stepsValue = padoInfo["steps"], let distanceValue = padoInfo["distance"] {
            DispatchQueue.main.async {
                if self.startStopButton.title(for: .normal) == "" {
                    self.activityView.isHidden = true
                    self.startStopButton.setTitle("Stop", for: .normal)
                    self.pauseResumeButton.isHidden = false
                    self.pauseResumeButton.setTitle("Pause", for: .normal)
                }
                self.pedoInformationView.isHidden = false
                self.stepsLabel.text = PedoRecorderInteractor.getFormatedStringFromNumber(number: stepsValue, withFractionDigit: 2)
                self.distanceLabel.text = PedoRecorderInteractor.getFormatedStringFromNumber(number: distanceValue, withFractionDigit: 0)
            }
            
        }
    }
    func didFailToReceivePedoInfo(errorMsg: String) {
        DispatchQueue.main.async {
            self.activityView.isHidden = true
            self.startStopButton.isHidden = true
            self.pauseResumeButton.isHidden = true
            self.pedoInformationView.isHidden = true
            self.welcomeLabel.textColor = UIColor.red
            self.welcomeLabel.text = errorMsg
        }
    }
}

