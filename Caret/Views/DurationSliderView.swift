//
//  DurationSliderView.swift
//  Caret
//
//  Created by Nate Armstrong on 2/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class DurationSliderView: UIControl {

  var phase = 0
  var numberOfPhases = 2
  var value: Double = 0.0
  var padding: CGFloat = 44
  var minimumValue: Double = 0.0 {
    didSet {
      setNeedsLayout()
    }
  }
  var maximumValue: Double = 1.0 {
    didSet {
      setNeedsLayout()
    }
  }
  var pixelMin: CGFloat {
    return 0 + padding
  }
  var pixelMax: CGFloat {
    return CGRectGetWidth(bounds) - padding
  }
  lazy var panGesture: PanPauseGestureRecognizer = {
    return PanPauseGestureRecognizer(target: self, action: "didPan:")
  }()

  lazy var pin: UIView = {
    let view = UIView(frame: CGRectMake(0, 0, 6.0, CGRectGetHeight(self.bounds)))
    view.layer.cornerRadius = 5.0
    view.layer.masksToBounds = true
    view.backgroundColor = UIColor.secondaryColor()
    return view
  }()

  lazy var gestureView: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    return view
  }()

  lazy var bottomBorder: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor.primaryColor()
    return view
  }()

  lazy var topBorder: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor.primaryColor()
    return view
  }()


  func setup() {
    backgroundColor = UIColor.primaryColor()
    addSubview(bottomBorder)
    addSubview(topBorder)
    addSubview(pin)
    gestureView.addGestureRecognizer(panGesture)
    addSubview(gestureView)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
  }

  override func layoutSubviews() {
    drawLines()
    gestureView.frame = bounds
    let height: CGFloat = 2
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(bounds) - height, CGRectGetWidth(bounds), height)
    topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), height)
  }

  func drawLines() {
    pin.frame.origin.x = CGFloat(whereIs(value, of: (minimumValue, maximumValue), within: (Double(pixelMin), Double(pixelMax))))
    for view in subviews {
      let v = view as! UIView
      if v != pin && v != gestureView && v != bottomBorder && v != topBorder {
        view.removeFromSuperview()
      }
    }
    var count: Double = 0
    while count <= maximumValue {
      let tall = count > 0 && count % 1.25 == 0
      let x = whereIs(count, of: (minimumValue, maximumValue), within: (0, Double(CGRectGetWidth(bounds))))
      let y = tall ? CGRectGetHeight(bounds) / 6 : CGRectGetHeight(bounds) / 3
      let width: CGFloat = tall ? 1.0 : 0.5
      let height = tall ? CGRectGetHeight(bounds) - y*2 : CGRectGetHeight(bounds) / 3
      var frame = CGRectMake(CGFloat(x), y, width, height)
      var line = UIView(frame: frame)
      line.backgroundColor = UIColor.whiteColor()
      if CGFloat(x) < CGRectGetMinX(bounds) || CGFloat(x) > CGRectGetMaxX(bounds) {
        line.backgroundColor = UIColor.clearColor()
      }
      line.alpha = tall ? 1.0 : 0.3
      insertSubview(line, atIndex: 0)
      count += 0.25
    }
  }

  func didPan(gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer.state == .Changed || gestureRecognizer.state == .Began {
      let panPauseGesture = gestureRecognizer as! PanPauseGestureRecognizer
      if panPauseGesture.paused {
        if phase++ < numberOfPhases - 1 {
          sendActionsForControlEvents(.ApplicationReserved)
          panPauseGesture.paused = false
          panPauseGesture.startTimer()
        }
      }
      let x = gestureRecognizer.locationInView(self).x
      if x >= 0 && x <= CGRectGetWidth(bounds) {
        var loc = gestureRecognizer.locationInView(self).x
        if loc > pixelMax {
          loc = pixelMax
        } else if loc < pixelMin {
          loc = pixelMin
        }
        pin.frame.origin.x = loc
        setValueForLocation(loc)
        sendActionsForControlEvents(.ValueChanged)
      }
    } else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
      phase = 0
      sendActionsForControlEvents(.EditingDidEnd)
    }
  }

  private func setValueForLocation(loc: CGFloat) {
    value = whereIs(Double(loc), of: (Double(pixelMin), Double(pixelMax)), within: (minimumValue, maximumValue))
  }

}
