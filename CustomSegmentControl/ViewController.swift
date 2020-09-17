//
//  ViewController.swift
//  CustomSegmentControl
//
//  Created by Surjit on 14/09/20.
//  Copyright © 2020 Surjit Chowdhary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var percentSwitch: PercentageSwitchView!
    @IBOutlet var segmentSwitch: SegmentSwitchView!
    
    let testSegmentSwitch = SegmentSwitchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        percentSwitch.delegate = self
        segmentSwitch.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    self.testSegmentSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(testSegmentSwitch)
        self.testSegmentSwitch.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
        self.testSegmentSwitch.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
        self.testSegmentSwitch.heightAnchor.constraint(equalToConstant: 150).isActive = true
        self.testSegmentSwitch.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        
        self.testSegmentSwitch.buttonText = "Light Shades"
        self.testSegmentSwitch.setState(state: .Close)
        
        self.percentSwitch.setState(state: .Zero)
    }

}

extension ViewController: SegmentSwitchDelegate {
    func getCurrentState(state: SegmentSwitchControl.SegmentState) {
        let values = "\(state)"
        print("Segment Switch value changed: \(values)")
    }
}

extension ViewController: PercentageSwitchDelegate {
    func getCurrentState(state: PercentageSwichControl.SegmentState) {
        let values = "\(state)"
        print("Segment Switch value changed: \(values)")
    }
}

