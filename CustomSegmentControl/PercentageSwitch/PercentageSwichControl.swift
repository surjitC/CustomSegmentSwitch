//
//  PercentageSwichControl.swift
//  CustomSegmentControl
//
//  Created by Surjit on 16/09/20.
//  Copyright © 2020 Surjit Chowdhary. All rights reserved.
//

import UIKit

class PercentageSwichControl: UIControl {
    
    enum SegmentState: Int {
        case Zero
        case OneFourth
        case Half
        case ThreeForth
        case Full
    }
    
    public var selectedState: SegmentState = .Zero

    public var isContinous = false
    private let trackLayer = SegmentProgressBarControlTrackLayer()
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
    private var offset: CGFloat = 0.0
    
    private var minimumValue: CGFloat = 0.0
    private var maximumValue: CGFloat = 1.0
    public var currentValue: CGFloat = 0.5
    
    private var trackHeight: CGFloat = 10.0
    
    private var widthForLabel: CGFloat = 48.0 {
        didSet {
            textsize = CGSize(width: widthForLabel, height: self.bounds.height)
            offset = widthForLabel * 2
        }
    }
    
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
    
    private var leftText = "OFF"
    private var rightText = "100%"
    
    private var thumbsize: CGSize = CGSize(width: 60, height: 60)
    private var textsize: CGSize = CGSize(width: 70, height: 60)
    
    private var stepLayerOne: CAShapeLayer?
    private var stepLayerTwo: CAShapeLayer?
    private var stepLayerThree: CAShapeLayer?
    private var leftCircle: CAShapeLayer?
    private var rightCircle: CAShapeLayer?
    
    var color: UIColor = UIColor.systemIndigo {
        didSet {
            updateColors()
        }
    }
    var bgColor: UIColor = UIColor.white {
        didSet {
            updateColors()
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
    
    public func toggleState(state: SegmentState) {
        self.changeState(state)
    }
    
    private func initializeViews() {
        addAllSubviews()
        
        setupTrackLayer()
        setupThumb()
        setupTextViews()
        
        currentValue = getCurrentValueFrom(state: selectedState)
        self.changeState(selectedState)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.leftCircle?.removeFromSuperlayer()
        self.rightCircle?.removeFromSuperlayer()
        
        self.leftCircle = CAShapeLayer()
        self.rightCircle = CAShapeLayer()
        
        let leftCirclePath = UIBezierPath(roundedRect: CGRect(x: trackLayer.frame.minX - trackHeight - 2, y: trackLayer.frame.minY, width: trackHeight, height: trackHeight), cornerRadius: trackHeight / 2)
        leftCircle?.path = leftCirclePath.cgPath
        leftCircle?.fillColor = color.cgColor
        if let layer = leftCircle {
            self.layer.addSublayer(layer)
        }
        
        let rightCirclePath = UIBezierPath(roundedRect: CGRect(x: trackLayer.frame.maxX + 2, y: trackLayer.frame.minY, width: trackHeight, height: trackHeight), cornerRadius: trackHeight / 2)
        rightCircle?.path = rightCirclePath.cgPath
        rightCircle?.fillColor = color.cgColor
        if let layer = rightCircle {
            self.layer.addSublayer(layer)
        }
        
        self.stepLayerOne?.removeFromSuperlayer()
        self.stepLayerTwo?.removeFromSuperlayer()
        self.stepLayerThree?.removeFromSuperlayer()
        
        self.stepLayerOne = CAShapeLayer()
        self.stepLayerTwo = CAShapeLayer()
        self.stepLayerThree = CAShapeLayer()
        
        self.addSteps(stepLayerOne, 0.25)
        self.addSteps(stepLayerTwo, 0.50)
        self.addSteps(stepLayerThree, 0.75)
    }
    
    private func addSteps(_ stepLayer: CAShapeLayer?, _ value: CGFloat) {

        let stepWidth: CGFloat = 3
        let stepHeightOffset: CGFloat = 10
        offset = widthForLabel * 1.25
        let trackLayerFrame = bounds.insetBy(dx: offset, dy: bounds.height / 2.25)
        let stepX = (trackLayerFrame.width * value) + trackLayerFrame.minX - (stepWidth / 2)
        let stepY = trackLayer.frame.minY - stepHeightOffset
        let stepHeight: CGFloat = trackLayer.frame.height + (2 * stepHeightOffset)
        
        let path = UIBezierPath(rect: CGRect(x: stepX, y: stepY, width: stepWidth, height: stepHeight))
        stepLayer?.path = path.cgPath
        
        if let stepLayer = stepLayer {
            self.layer.addSublayer(stepLayer)
        }
        self.trackLayer.zPosition = 1
    }
    
    private func addAllSubviews() {
        self.layer.addSublayer(trackLayer)
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
        self.addSubview(thumbButton)
        self.bringSubviewToFront(thumbButton)
    }
    
    private func setupTrackLayer() {
        trackLayer.percentageSwitchControl = self
        trackLayer.contentsScale = UIScreen.main.scale

    }
    
    private func setupThumb() {
        thumbButton.layer.cornerRadius = thumbsize.height / 2
        thumbButton.isUserInteractionEnabled = false
        thumbButton.layer.backgroundColor = self.bgColor.cgColor
        thumbButton.layer.borderWidth = 2.0
        thumbButton.layer.borderColor = self.color.cgColor
        let selectedText = getCurrentText()
        thumbButton.setTitle(selectedText, for: .normal)
        thumbButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        thumbButton.layer.shadowOffset = thumbShadowOffset
        thumbButton.layer.shadowOpacity = thumbShadowOpacity
        thumbButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        thumbButton.layer.shadowRadius = thumbShadowRadius
        thumbButton.layer.zPosition = 2
    }
    
    private func setupTextViews() {
        leftLabel.text = self.leftText
        rightLabel.text = self.rightText
    }
    
    private func updateColors() {
        thumbButton.setTitleColor(color, for: .normal)
        thumbButton.layer.borderColor = color.cgColor
        self.layer.backgroundColor = self.bgColor.cgColor
        stepLayerOne?.fillColor = color.cgColor
        stepLayerTwo?.fillColor = color.cgColor
        stepLayerThree?.fillColor = color.cgColor
        leftCircle?.fillColor = color.cgColor
        rightCircle?.fillColor = color.cgColor
        self.setLabelColor()
    }
    
    private func updateLayerFrames() {
        offset = widthForLabel * 1.25
        let trackLayerY = (bounds.height - self.trackHeight) / 2
        trackLayer.frame = CGRect(x: offset, y: trackLayerY, width: bounds.width - 2 * offset, height: self.trackHeight)
        
        trackLayer.setNeedsDisplay()
        thumbButton.frame = CGRect(origin: thumbOriginForValue(currentValue), size: thumbsize)
        leftLabel.frame = CGRect(origin: labelForValueLeft(minimumValue), size: textsize)
        rightLabel.frame = CGRect(origin: labelForValueRight(maximumValue), size: textsize)
        self.setLabelColor()
    }

    func positionForValue(_ value: CGFloat) -> CGFloat {
        return (trackLayer.bounds.width * value) + offset
    }
    
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbsize.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbsize.height) / 2.0)
    }
    
    private func labelForValueLeft(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - textsize.width
        return CGPoint(x: x, y: (bounds.height - thumbsize.height) / 2.0)
    }
    
    private func labelForValueRight(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) + 4.0
        return CGPoint(x: x, y: (bounds.height - thumbsize.height) / 2.0)
    }
    
    fileprivate func changeState(_ currentSelectedState: SegmentState) {
        if !isContinous {
            self.currentValue = getCurrentValueFrom(state: currentSelectedState)
        }
        
        let title = getCurrentText()
        self.thumbButton.setTitle(title, for: .normal)
        UIView.animate(withDuration: 0.2) {
            
            self.thumbButton.frame = CGRect(origin: self.thumbOriginForValue(self.currentValue), size: self.thumbsize)
            
            
            if currentSelectedState != self.selectedState {
                self.selectedState = currentSelectedState
                self.setLabelColor()
                self.trackLayer.setNeedsDisplay()
                self.sendActions(for: .valueChanged)
            }
            
        }
    }
    
    public func thumbFinalState() {
        let currentSelectedState = getCurrentStateFrom(value: currentValue)
        changeState(currentSelectedState)
    }
    
    private func setLabelColor() {
        switch selectedState {
        case .Zero:
            leftLabel.textColor = self.bgColor
            rightLabel.textColor = color
        case .Full:
            rightLabel.textColor = self.bgColor
            leftLabel.textColor = color
        default:
            leftLabel.textColor = color
            rightLabel.textColor = color
        }
        
    }
    
    private func getCurrentValueFrom(state: SegmentState) -> CGFloat {
        switch state {
        case .Zero:
            return minimumValue
        case .OneFourth:
            return 0.25
        case .Half:
            return 0.5
        case .ThreeForth:
            return 0.75
        case .Full:
            return maximumValue
        }
    }
    
    private func getCurrentStateFrom(value: CGFloat) -> SegmentState {
        switch value {
        case 0..<0.125:
            return .Zero
        case 0.125..<0.375:
            return .OneFourth
        case 0.375..<0.625:
            return .Half
        case 0.625...0.875:
            return .ThreeForth
        case 0.875...1.0:
            return .Full
        default:
            return .Zero
        }
    }
    
    private func getCurrentText() -> String {
        let percentage = Int(currentValue * 100)
        if percentage == 0 {
            return "OFF"
        }
        return "\(percentage)%"
    }

}

extension PercentageSwichControl {
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
        
        let title = getCurrentText()
        self.thumbButton.setTitle(title, for: .normal)

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

class SegmentProgressBarControlTrackLayer: CALayer {
    weak var percentageSwitchControl: PercentageSwichControl?
    
    override func draw(in ctx: CGContext) {
        guard let segmentSwitchControl = percentageSwitchControl else { return }
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 0.0)
        ctx.addPath(path.cgPath)
        self.borderWidth = 1.0
        self.borderColor = segmentSwitchControl.bgColor.cgColor
//        self.cornerRadius = bounds.height / 2
        ctx.setFillColor(segmentSwitchControl.color.cgColor)
        ctx.fillPath()
    }
}
