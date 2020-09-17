//
//  PercentageSwitchView.swift
//  CustomSegmentControl
//
//  Created by Surjit on 16/09/20.
//  Copyright © 2020 Surjit Chowdhary. All rights reserved.
//

import UIKit

protocol PercentageSwitchDelegate: AnyObject {
    func getCurrentState(state: PercentageSwichControl.SegmentState)
}

@IBDesignable
class PercentageSwitchView: UIView {
    
    @IBInspectable open var color: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var bgColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var segmentColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var thumbColor: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isDisabledUI: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var buttonView: UIView = {
        return UIView()
    }()
    
    private var buttonImageView: UIImageView = {
        let buttonImageView = UIImageView()
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        return buttonImageView
    }()
    
    public var buttonImage: UIImage = #imageLiteral(resourceName: "Shade") {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var buttonText: String = "Sun Shade" {
        didSet {
            setNeedsDisplay()
        }
    }
    private var buttonTitleLabel: UILabel = {
        let buttonTitleLabel = UILabel()
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonTitleLabel.numberOfLines = 2
        buttonTitleLabel.textColor = .white
        buttonTitleLabel.textAlignment = .center
        buttonTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return buttonTitleLabel
    }()
    
    private var buttonTint: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var xOffset: CGFloat = 0
    private var currentSegmentState: PercentageSwichControl.SegmentState = .Zero
    private var previousSegmentState: PercentageSwichControl.SegmentState = .Half
    private var height: CGFloat = 0.0
    private var width: CGFloat = 0.0
    private var buttonWidth: CGFloat = 0.0
    private var percentageSwitchControl = PercentageSwichControl(frame: .zero)
    
    public weak var delegate: PercentageSwitchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.percentageSwitchControl.addTarget(self, action: #selector(segmentSwitchValueChanged(_:)), for: .valueChanged)
        self.backgroundColor = self.bgColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.height = self.frame.height
        self.width = self.frame.width
        
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        self.addSubview(buttonView)
        buttonView.addSubview(buttonImageView)
        buttonView.addSubview(buttonTitleLabel)
        
        self.buttonWidth = min(150, height)
        buttonView.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: height)
        buttonView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleState(_:)))
        buttonView.addGestureRecognizer(tapGesture)
        
        self.addViewAnchors()
        
        buttonImageView.image = self.buttonImage
        self.buttonTitleLabel.text = buttonText
        self.setButtonState()
    }
    
    private func addViewAnchors() {
        buttonImageView.heightAnchor.constraint(equalToConstant: height/2).isActive = true
        buttonImageView.widthAnchor.constraint(equalToConstant: height/2).isActive = true
        buttonImageView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor).isActive = true
        buttonImageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor, constant: -16).isActive = true
        
        buttonTitleLabel.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 6).isActive = true
        buttonTitleLabel.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -6).isActive = true
        buttonTitleLabel.topAnchor.constraint(equalTo: buttonImageView.bottomAnchor, constant: 2).isActive = true
        buttonTitleLabel.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        self.xOffset = self.buttonWidth
        let margin: CGFloat = 0
        let segmentControlWidth: CGFloat = self.frame.width - self.xOffset - 2 * margin
        let percentageControlHeight: CGFloat = self.frame.height
        let segmentX = self.xOffset + margin
        let segmentY = self.bounds.midY - percentageControlHeight / 2
        
        self.addSubview(percentageSwitchControl)
        
        self.percentageSwitchControl.frame = CGRect(x: segmentX, y: segmentY, width: segmentControlWidth, height: percentageControlHeight)
        
        self.setButtonState()
        
    }
    
    @objc func toggleState(_ sender: UITapGestureRecognizer) {
        self.currentSegmentState = currentSegmentState != .Zero ? .Zero : self.previousSegmentState
        percentageSwitchControl.toggleState(state: self.currentSegmentState)
    }
    
    @objc func segmentSwitchValueChanged(_ segmentSwitch: PercentageSwichControl) {
        self.currentSegmentState = segmentSwitch.selectedState
        if self.currentSegmentState != .Zero {
            self.previousSegmentState = self.currentSegmentState
        }
        self.setButtonState()
        self.delegate?.getCurrentState(state: self.currentSegmentState)
    }
    
    private func setButtonState() {
        guard isDisabledUI else { return }
        switch self.currentSegmentState {
        case .Zero:
            self.buttonTitleLabel.textColor = .gray
            self.buttonView.backgroundColor = .lightGray
            self.buttonImageView.tintColor = .gray
            self.layer.borderColor = UIColor.gray.cgColor
            self.percentageSwitchControl.color = .gray
            self.percentageSwitchControl.bgColor = self.bgColor
        default:
            self.buttonView.backgroundColor = color
            self.buttonImageView.tintColor = self.buttonTint
            self.buttonTitleLabel.textColor = self.buttonTint
            self.layer.borderColor = color.cgColor
            self.percentageSwitchControl.color = self.segmentColor
            self.percentageSwitchControl.bgColor = self.bgColor
        }
    }
    
    public func setState(state: PercentageSwichControl.SegmentState) {
        self.currentSegmentState = state
        self.previousSegmentState = state == .Zero ? .Half : state
        self.percentageSwitchControl.toggleState(state: self.currentSegmentState)
    }
}
