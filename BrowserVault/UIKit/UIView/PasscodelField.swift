//
//  PasscodelField.swift
//  LifeSite
//
//  Created by Thanh Duong on 6/21/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import UIKit

protocol PasscodelFieldDelegate {
    func didFullText(with textField: PasscodelField)
}

@IBDesignable
public class PasscodelField: UIControl, UIKeyInput {
    
    var delegate:PasscodelFieldDelegate?
    // MARK: - Public variables
  
    private var maxNumberOfDigits: Int = 6
    
    @IBInspectable public var numberOfDigits: Int = 6 {
        didSet {
            if numberOfDigits > maxNumberOfDigits {
                numberOfDigits = maxNumberOfDigits
            }
            if oldValue != numberOfDigits {

                if passcode.count > numberOfDigits {
                    let endOfString = passcode.index(passcode.startIndex, offsetBy: numberOfDigits)
                    if endOfString <= passcode.endIndex {
                        passcode = String(passcode[passcode.startIndex..<endOfString])
                    }
                }

                relayout()
                redisplay()
            }

        }
    }

    @IBInspectable public var passcode: String = "" {
        didSet {

            if oldValue != passcode {

                guard passcode.count <= numberOfDigits else {
                    return
                }

                guard isNumeric(passcode) else {
                    return
                }

                redisplay()
                sendActions(for: .valueChanged)

            }
        }
    }

    @IBInspectable public var spaceBetweenDigits: CGFloat = 10.0 {

        didSet {

            if oldValue != spaceBetweenDigits {

                relayout()
                redisplay()

            }
        }

    }

    @IBInspectable public var dashColor: UIColor = UIColor.white {
        didSet {

            if oldValue != dashColor {
                redisplay()
            }

        }
    }

    @IBInspectable public var textColor: UIColor = UIColor.black {
        didSet {
            if oldValue != textColor {
                redisplay()
            }
        }
    }

    @IBInspectable public var dashBackColor: UIColor = UIColor.green {
        didSet {
            if oldValue != dashBackColor {
                redisplay()
            }
        }
    }

    @IBInspectable public var backColor: UIColor = UIColor.yellow {
        didSet {
            if oldValue != backColor {
                redisplay()
            }
        }
    }
    
    @IBInspectable public var emptyDigit: String = "○" {
        didSet {
            if oldValue != emptyDigit {
                relayout()
                redisplay()
            }
        }
    }

    // MARK: - Private variables
    private var numberLabels: [PasscodelLabel] = []
    private var isSecure = false {
        didSet {
            if isSecure != oldValue {
                redisplay()
            }
        }
    }


    // MARK: - UIView

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public func layoutSubviews() {

        for index in 0..<numberLabels.count {
            let label = numberLabels[index]
            let frame = frameOfNumberLabel(ofDigitIndex: index)
            label.label.font = UIFont.systemFont(ofSize: frame.size.width)
            label.label.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            label.frame = frame
        }

    }


    // MARK: - Private methods
    private func setup() {

        addTarget(self, action: #selector(PasscodelField.didTouchUpInside), for: .touchUpInside)
        relayout()

    }

    private func relayout() {
        numberLabels.forEach { label in
            label.removeFromSuperview()
        }
        numberLabels = []

        for _ in 0..<numberOfDigits {
            let numberLabel = PasscodelLabel()
            numberLabel.label.text = emptyDigit
            numberLabel.label.textColor = dashColor
            numberLabel.label.textAlignment = .center
            numberLabels.append(numberLabel)
            addSubview(numberLabel)
        }

        setNeedsLayout()

    }


    private func frameOfNumberLabel(ofDigitIndex index:Int) -> CGRect {

        let w = (bounds.size.width - spaceBetweenDigits * (CGFloat(maxNumberOfDigits) - 1.0)) / CGFloat(maxNumberOfDigits)
        var x: CGFloat!
        if numberOfDigits < maxNumberOfDigits {
            let boundUpdate = w * CGFloat(numberOfDigits) + ((CGFloat(numberOfDigits) - 1.0) * CGFloat(spaceBetweenDigits))
            let leftSpace = (bounds.size.width - boundUpdate) / 2
            let spaceUpdate = (boundUpdate - w * CGFloat(numberOfDigits)) / (CGFloat(numberOfDigits) - 1.0)
            x = (w + spaceUpdate) * CGFloat(index) + leftSpace
        } else {
            let spaceUpdate = (bounds.size.width - w * CGFloat(maxNumberOfDigits)) / (CGFloat(maxNumberOfDigits) - 1.0)
            x = (w + spaceUpdate) * CGFloat(index)
        }
        let y = CGFloat(0)
        return CGRect(x:x, y:y, width:w, height:w)

    }

    private func redisplay() {

        for i in 0..<numberOfDigits {

            let label = numberLabels[i]

            if i < passcode.count {

                let start = passcode.index(passcode.startIndex, offsetBy: i)
                let end = passcode.index(start, offsetBy: 1)
                let number = String(passcode[start..<end])
                
                label.label.text = isSecureTextEntry ? "●" : number
                label.label.textColor = textColor
                label.backgroundColor = backColor

            } else {

                label.label.text = emptyDigit
                label.label.textColor = dashColor
                label.backgroundColor = dashBackColor
                
            }
        }

    }

    private func isNumeric(_ string:String) -> Bool {

        guard let regex = try? NSRegularExpression(pattern: "^[0-9]*$", options: []) else {
            return false
        }

        return regex.numberOfMatches(in: string, options: [], range: NSMakeRange(0, string.count)) == 1
    }

    // MARK: - Handle the touch up event
    @objc private func didTouchUpInside() {
        becomeFirstResponder()
    }

    // MARK: UIKeyInput protocol
    public var hasText: Bool {
        return !passcode.isEmpty
    }

    public func insertText(_ text: String) {

        guard passcode.count + text.count <= numberOfDigits else {
            return
        }

        guard isNumeric(text) else {
            return
        }

        passcode = passcode + text

        if passcode.count == numberOfDigits {
            self.delegate?.didFullText(with: self)
        }
    }

    public func deleteBackward() {
        guard passcode.count > 0 else {
            return
        }
        let endIndex = passcode.index(before: passcode.endIndex)
        passcode = String(passcode[passcode.startIndex..<endIndex])
    }

    public var isSecureTextEntry: Bool {
        @objc(isSecureTextEntry) get {
            return isSecure
        }
        @objc(setSecureTextEntry:) set {
            isSecure = newValue
        }
    }

    // MARK: UIResponder
    public override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: UIKeyboardTrait

    public var keyboardType: UIKeyboardType {
        set {}
        get {
            return .numberPad
        }
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
                return false
            }
            // Default
            return super.canPerformAction(action, withSender: sender)
        }


}

class PasscodelLabel: UIView {
    
    
    lazy var label: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.label.textAlignment = .center
        self.addSubview(self.label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
