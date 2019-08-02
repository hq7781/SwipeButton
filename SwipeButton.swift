//
//  SwipeButton.swift
//  abcmart
//
//  Created by 洪 権 on 2019/06/13.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit

@IBDesignable class SwipeButton: UIView {
    @IBInspectable var borderColor:  UIColor = UIColor.black
    @IBInspectable var borderWidth:  CGFloat = 1.5
    @IBInspectable var cornerRadius: CGFloat = 10.0
    @IBInspectable var duration:     Double  = 0.8
    
    @IBInspectable var frontColor : UIColor = UIColor.abcYellow {
        didSet {
            self.button.backgroundColor = frontColor
        }
    }
    @IBInspectable var groundColor : UIColor = UIColor.gray {
        didSet {
            self.bar.backgroundColor = groundColor
        }
    }
    @IBInspectable var backColor : UIColor = UIColor.clear {
        didSet {
            self.backgroundColor = backColor
        }
    }
    @IBInspectable var textColor : UIColor = UIColor.lightGray {
        didSet {
            self.textLabel.textColor = textColor
        }
    }

    @IBInspectable var swipedFrontColor : UIColor = UIColor.red
    @IBInspectable var swipedGroundColor : UIColor = UIColor.darkGray
    @IBInspectable var swipedTextColor : UIColor = UIColor.abcYellow

    @IBInspectable var textFont : UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            self.textLabel.font = textFont
        }
    }

    @IBInspectable var barHeight: CGFloat = 40.0 {
        didSet {
            self.layoutSubviews()
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            self.layoutSubviews()
        }
    }
    
    public var isRightToLeft: Bool = true {
        didSet {
            self.layoutSubviews()
        }
    }

    public var text: String? = nil {
        didSet {
         self.layoutSubviews()
        }
    }
    public var swipedText: String?
    
    private var startFrame:CGRect!
    private var turnedFrame:CGRect!
    private var moveTo = CGFloat(0)
    
    public lazy var textLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = textColor
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = textFont
        return label
        }()

    public lazy var bar: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = groundColor
        return view
        }()

    public lazy var button: RoundView = { [unowned self] in
        let view = RoundView()
        view.backgroundColor = frontColor
        view.delegate = self
        return view
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInt()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commInt()
    }

    public convenience init(_ text: String?) {
        self.init()
        self.text = text
        self.commInt()
    }
    func commInt() {
        self.backgroundColor = backColor

        self.addSubview(bar)
        self.bar.addSubview(textLabel)
        self.addSubview(button)
        self.bringSubviewToFront(button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maxWidth: CGFloat = self.frame.width
        let maxHeight: CGFloat = self.frame.height
        if barHeight > maxHeight {
            barHeight = maxHeight
        }
        if barHeight < 10 {
            textLabel.isHidden = true
        }
        self.bar.frame = CGRect(x: 0, y: (maxHeight - barHeight) / 2, width: maxWidth, height: barHeight)
        if self.text != nil,!textLabel.isHidden {
            textLabel.text = self.text
            textLabel.frame = CGRect(origin: .zero, size: bar.frame.size)
        } else {
            textLabel.frame = CGRect.zero
        }
        let leftFrame = CGRect(x: 0, y: 0, width: maxHeight, height: maxHeight)
        let rightFrame  = CGRect(x: (maxWidth - maxHeight), y: 0, width: maxHeight, height: maxHeight)
        if isRightToLeft {
            self.startFrame = rightFrame
            self.turnedFrame = leftFrame
        } else {
            self.startFrame = leftFrame
            self.turnedFrame = rightFrame
        }
        button.frame = startFrame
        
        if isEnabled {
            button.isUserInteractionEnabled = true
        } else {
            button.isUserInteractionEnabled = false
        }
        self.corner(bar)
        self.corner(button)
        if borderWidth > 0 {
            self.bouder(bar, width: borderWidth, color: borderColor)
        }
    }
}

extension SwipeButton {
    func bouder(_ view: UIView, width: CGFloat, color: UIColor) {
        view.layer.masksToBounds = true
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
    }

    func corner(_ view: UIView, radius: CGFloat = 0) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = (radius > 0) ? radius : (view.frame.height / 2)
    }
}

extension SwipeButton {
    func swipeToGo() {
        UIView.animate(withDuration: self.duration, animations: {
                self.button.frame = self.turnedFrame
        }){ (completed) in
            self.button.backgroundColor = self.swipedFrontColor
            self.bar.backgroundColor = self.swipedGroundColor
            self.textLabel.textColor = self.swipedTextColor
            if let swipedText = self.swipedText {
            self.textLabel.text = swipedText
            }
        }
    }
    
    func swipeToBack() {
        UIView.animate(withDuration: self.duration, animations: {
            self.button.frame = self.startFrame
        }){ (completed) in
            self.button.backgroundColor = self.frontColor
            self.bar.backgroundColor = self.groundColor
            self.textLabel.textColor = self.textColor
            if let text = self.text {
                self.textLabel.text = text
            } else {
                self.textLabel.text = nil
            }
        }
    }
}

// MARK: - RoundViewDelegate
extension SwipeButton : RoundViewDelegate{
    func roundViewTouchesEnded() {
        if self.button.center.x > (self.frame.width / 2) {
            if self.isRightToLeft {
                swipeToBack()
            } else {
                swipeToGo()
            }
        } else {
            if self.isRightToLeft {
                swipeToGo()
            } else {
                swipeToBack()
            }
        }
    }
}
protocol RoundViewDelegate: class {
    func roundViewTouchesEnded() -> Void
}

class RoundView: UIView {
    weak var delegate: RoundViewDelegate?
    public var touchSize: CGSize!
    private var locationInitialTouch:CGPoint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let location = touch.location(in: self)
        print(" Began:(\(location.x), \(location.y))")
        locationInitialTouch = location
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let location = touch.location(in: self)
        if location.x < 0 || location.x > touchSize.width { return }
        if location.y < 0 || location.y > touchSize.height { return }
        print(" Moved:(\(location.x), \(location.y))")
        let f = frame.offsetBy(dx: location.x - locationInitialTouch.x, dy: 0)
        if (f.minX >= 0 && f.maxX <= touchSize.width) {
            frame = f
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            delegate?.roundViewTouchesEnded()
        }
        guard let touch = touches.first else{
            return
        }
        let location = touch.location(in: self)
        if location.x < 0 || location.x > touchSize.width {
            return
        }
        if location.y < 0 || location.y > touchSize.height {
            return
        }
        print(" Ended:(\(location.x), \(location.y))")
        let f = frame.offsetBy(dx: location.x - locationInitialTouch.x, dy: 0)
        if (f.minX >= 0 && f.maxX <= touchSize.width) {
            frame = f
        }
    }
}
