//
//  SegmentSwitchControl.swift
//  SegmentSwitchControl
//
//  Created by Surjit on 09/09/20.
//  Copyright © 2020 Surjit Chowdhary. All rights reserved.
//

import UIKit

class SegmentSwitchControl: UIControl {
    
    enum SegmentState: Int {
        case Open
        case Close
    }
    
    public var selectedState: SegmentState = .Open
    public var isContinous = false
    private let trackLayer = SegmentSwitchControlTrackLayer()
    private let thumbButton = UIButton(type: .custom)
    
    private let leftLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private var previousLocation = CGPoint()
    private var divider: CAShapeLayer?
    
    private var minimumValue: CGFloat = 0.25
    private var maximumValue: CGFloat = 0.75
    private var currentValue: CGFloat = 0.25
    
    private var trackHeight: CGFloat = 36.0
    
    var thumbShadowOffset = CGSize(width: 0.0, height: 0.0) {
        didSet {
            thumbButton.layer.shadowOffset = thumbShadowOffset
            self.setNeedsDisplay()
        }
    }
    
    var thumbShadowOpacity: Float = 0.7 {
        didSet {
            thumbButton.layer.shadowOpacity = thumbShadowOpacity
            self.setNeedsDisplay()
        }
    }
    
    var thumbShadowRadius: CGFloat = 7 {
        didSet {
            thumbButton.layer.shadowRadius = thumbShadowRadius
            self.setNeedsDisplay()
        }
    }
    
    private var leftText = "OPEN"
    private var rightText = "CLOSE"
    
    private var thumbsize: CGSize = CGSize(width: 64, height: 64)
    
    public var color: UIColor = UIColor.systemIndigo {
        didSet {
            updateColors()
        }
    }
    
    public var bgColor: UIColor = UIColor.white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeViews()
    }
    
    override func draw(_ rect: CGRect) {
         super.draw(rect)
         
        self.divider?.removeFromSuperlayer()
        self.divider = CAShapeLayer()
        
        let path = UIBezierPath(rect: CGRect(x: trackLayer.bounds.width / 2, y: trackLayer.frame.minY, width: 2, height: trackHeight))
        
        self.divider?.path = path.cgPath
        
        if let divider = self.divider {
            self.layer.addSublayer(divider)
        }
        self.divider?.zPosition = 1
        self.updateColors()
     }
    
    private func initializeViews() {
        addAllSubviews()
        
        setupTrackLayer()
        setupThumb()
        setupTextViews()
        
        currentValue = selectedState == .Open ? minimumValue : maximumValue
    }
    
    private func setupTextViews() {
        leftLabel.text = self.leftText
        rightLabel.text = self.rightText
    }
    
    public func toggleState(state: SegmentState) {

        self.changeState(state)
    }
    
    private func addAllSubviews() {
        self.layer.addSublayer(trackLayer)
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
        self.addSubview(thumbButton)
    }
    
    private func setupTrackLayer() {
        trackLayer.segmentSwitchControl = self
        trackLayer.contentsScale = UIScreen.main.scale
    }
    
    private func setupThumb() {
        thumbButton.layer.cornerRadius = thumbsize.height / 2
        thumbButton.isUserInteractionEnabled = false
        thumbButton.backgroundColor = self.bgColor
        thumbButton.layer.borderWidth = 2.0
        thumbButton.layer.borderColor = self.color.cgColor
        let selectedText = selectedState == .Open ? leftText : rightText
        thumbButton.setTitle(selectedText, for: .normal)
        thumbButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        thumbButton.layer.shadowOffset = thumbShadowOffset
        thumbButton.layer.shadowOpacity = thumbShadowOpacity
        thumbButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        thumbButton.layer.shadowRadius = thumbShadowRadius
        thumbButton.layer.zPosition = 2
    }
        
    private func updateColors() {
        thumbButton.setTitleColor(color, for: .normal)
        thumbButton.layer.borderColor = color.cgColor
        self.layer.backgroundColor = self.bgColor.cgColor
        self.setLabelColor()
    }
    
    private func updateLayerFrames() {
        let offset: CGFloat = 0.0
        let trackLayerY = (bounds.height - self.trackHeight) / 2
        trackLayer.frame = CGRect(x: offset, y: trackLayerY, width: bounds.width - 2 * offset, height: self.trackHeight)
        trackLayer.setNeedsDisplay()
        thumbButton.frame = CGRect(origin: thumbOriginForValue(currentValue), size: thumbsize)
        leftLabel.frame = CGRect(origin: labelForValue(minimumValue), size: thumbsize)
        rightLabel.frame = CGRect(origin: labelForValue(maximumValue), size: thumbsize)
        self.setLabelColor()
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbsize.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbsize.height) / 2.0)
    }
    
    private func labelForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbsize.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbsize.height) / 2.0)
    }
    
    fileprivate func changeState(_ currentSelectedState: SegmentSwitchControl.SegmentState) {
        let title = currentSelectedState == .Open ? leftText : rightText
        self.currentValue = currentSelectedState == .Open ? minimumValue : maximumValue
        UIView.animate(withDuration: 0.2) {
            
            self.thumbButton.frame = CGRect(origin: self.thumbOriginForValue(self.currentValue), size: self.thumbsize)
            self.thumbButton.setTitle(title, for: .normal)
            
            if currentSelectedState != self.selectedState {
                self.selectedState = currentSelectedState
                self.setLabelColor()
                self.trackLayer.setNeedsDisplay()
                self.sendActions(for: .valueChanged)
            }
            
        }
    }
    
    private func thumbFinalState() {
        if !isContinous {
            currentValue = currentValue < 0.5 ? minimumValue : maximumValue
        }
        
        let currentSelectedState = currentValue < 0.5 ? SegmentState.Open : SegmentState.Close
        changeState(currentSelectedState)
    }
    
    private func setLabelColor() {
        switch selectedState {
        case .Open:
            leftLabel.textColor = color
            rightLabel.textColor = color
            divider?.fillColor = color.cgColor
        default:
            leftLabel.textColor = bgColor
            rightLabel.textColor = bgColor
            divider?.fillColor = bgColor.cgColor
        }
    }
    
}

extension SegmentSwitchControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if thumbButton.frame.contains(previousLocation) {
            thumbButton.isHighlighted = true
        }
        return thumbButton.isHighlighted
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        if thumbButton.isHighlighted {
            currentValue += deltaValue
            currentValue = boundValue(currentValue, toLowerValue: minimumValue, upperValue: maximumValue)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbButton.isHighlighted = false
        self.thumbFinalState()
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
}

class SegmentSwitchControlTrackLayer: CALayer {
    weak var segmentSwitchControl: SegmentSwitchControl?
    
    override func draw(in ctx: CGContext) {
        guard let segmentSwitchControl = segmentSwitchControl else { return }
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
        ctx.addPath(path.cgPath)
        ctx.addLines(between: [CGPoint(x: bounds.width / 2, y: 0), CGPoint(x: bounds.width / 2, y: bounds.height)])
        
        self.borderWidth = 2.0
        self.borderColor = segmentSwitchControl.color.cgColor
        self.cornerRadius = bounds.height / 2
        
        switch segmentSwitchControl.selectedState {
        case .Open:
            ctx.setFillColor(segmentSwitchControl.bgColor.cgColor)
        default:
            ctx.setFillColor(segmentSwitchControl.color.cgColor)
        }
        ctx.fillPath()
    }
    
}
