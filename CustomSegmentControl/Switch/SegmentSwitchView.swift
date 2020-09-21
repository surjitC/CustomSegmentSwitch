//
//  SegmentSwitchControl.swift
//  SegmentSwitchControl
//
//  Created by Surjit on 08/09/20.
//  Copyright © 2020 Surjit Chowdhary. All rights reserved.
//

import UIKit

protocol SegmentSwitchDelegate: AnyObject {
    func getCurrentState(state: SegmentSwitchControl.SegmentState)
}

@IBDesignable
class SegmentSwitchView: UIView {
    
    @IBInspectable open var color: UIColor = UIColor.systemIndigo {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var bgColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var segmentColor: UIColor = UIColor.systemIndigo {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var thumbColor: UIColor = UIColor.systemIndigo {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var buttonImage: UIImage = #imageLiteral(resourceName: "WhiteLight") {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var buttonText: String = "Black Shade" {
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
    private var currentSegmentState: SegmentSwitchControl.SegmentState = .Open
    private var height: CGFloat = 0.0
    private var width: CGFloat = 0.0
    private var buttonWidth: CGFloat = 0.0
    private var segmentSwitchControl = SegmentSwitchControl(frame: .zero)
    
    public weak var delegate: SegmentSwitchDelegate?
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapGestureRecognized(_ :)))
        self.segmentSwitchControl.gestureRecognizers = [tapGesture]
        self.segmentSwitchControl.addTarget(self, action: #selector(segmentSwitchValueChanged(_:)), for: .valueChanged)
        self.backgroundColor = self.bgColor
    }

    @objc private func sliderTapGestureRecognized(_ recognizer: UIGestureRecognizer) {
        handleSliderGestureRecognizer(recognizer)
        switch recognizer.state {
        case .ended:
            self.segmentSwitchControl.thumbFinalState()
        default:
            break
        }
    }

    private func handleSliderGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        if let recognizerView = recognizer.view, recognizerView.isKind(of: SegmentSwitchControl.self) {
            if let segmentSwitch = recognizer.view as? SegmentSwitchControl {
                let point = recognizer.location(in: recognizerView)
                let width = segmentSwitch.frame.width
                let percentage = point.x / width
                self.segmentSwitchControl.currentValue = percentage < 0.5 ? 0.25 : 0.75
                currentSegmentState = percentage < 0.5 ? .Open : .Close
            }
        }
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.height = self.frame.height
        self.width = self.frame.width
        
        self.layer.borderWidth = 2.0
        self.layer.borderColor = self.color.cgColor
        self.layer.cornerRadius = self.cornerRadius
        self.clipsToBounds = true
        
        self.addButtonView()
        self.addViewAnchors()
        
        self.buttonView.backgroundColor = self.color
        self.buttonImageView.image = self.buttonImage
        self.buttonTitleLabel.text = self.buttonText
        self.buttonImageView.tintColor = self.buttonTint
    }
    
    private func addButtonView() {
        self.addSubview(self.buttonView)
        self.buttonView.addSubview(self.buttonImageView)
        self.buttonView.addSubview(self.buttonTitleLabel)
        
        self.buttonWidth = min(150, height)
        buttonView.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleState(_:)))
        self.buttonView.addGestureRecognizer(tapGesture)
    }
    
    private func addViewAnchors() {
        self.buttonImageView.heightAnchor.constraint(equalToConstant: self.height/2).isActive = true
        self.buttonImageView.widthAnchor.constraint(equalToConstant: self.height/2).isActive = true
        self.buttonImageView.centerXAnchor.constraint(equalTo: self.buttonView.centerXAnchor).isActive = true
        self.buttonImageView.centerYAnchor.constraint(equalTo: self.buttonView.centerYAnchor, constant: -16).isActive = true
        self.buttonTitleLabel.leadingAnchor.constraint(equalTo: self.buttonView.leadingAnchor, constant: 6).isActive = true
        self.buttonTitleLabel.trailingAnchor.constraint(equalTo: self.buttonView.trailingAnchor, constant: -6).isActive = true
        self.buttonTitleLabel.topAnchor.constraint(equalTo: self.buttonImageView.bottomAnchor, constant: 2).isActive = true
        self.buttonTitleLabel.bottomAnchor.constraint(equalTo: self.buttonView.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        self.xOffset = self.buttonWidth
        self.addSegmentControl()
        
    }
    
    private func addSegmentControl() {
        let margin: CGFloat = 20
        let segmentControlWidth: CGFloat = self.frame.width - self.xOffset - 2 * margin
        let segmentControlHeight: CGFloat = self.frame.height
        let segmentX = self.xOffset + margin
        let segmentY = self.bounds.midY - segmentControlHeight / 2
        
        self.addSubview(self.segmentSwitchControl)
        
        self.segmentSwitchControl.frame = CGRect(x: segmentX, y: segmentY, width: segmentControlWidth, height: segmentControlHeight)
        
        self.segmentSwitchControl.color = self.segmentColor
        self.segmentSwitchControl.bgColor = self.bgColor
    }
    
    @objc func toggleState(_ sender: UITapGestureRecognizer) {
        self.currentSegmentState = currentSegmentState == .Open ? .Close : .Open
        self.segmentSwitchControl.toggleState(state: self.currentSegmentState)
    }
    
    @objc func segmentSwitchValueChanged(_ segmentSwitch: SegmentSwitchControl) {
        self.currentSegmentState = segmentSwitch.selectedState
        self.delegate?.getCurrentState(state: self.currentSegmentState)
    }
    
    public func setState(state: SegmentSwitchControl.SegmentState) {
        self.currentSegmentState = state
        self.segmentSwitchControl.toggleState(state: self.currentSegmentState)
    }
}
