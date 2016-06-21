//
//  Helpers.swift
//  Tac!
//
//  Created by Andrew Fashion on 9/12/15.
//  Copyright (c) 2015 Andrew Fashion. All rights reserved.
//

import Foundation



func startLoader(title: String, view: UIView) {
    let loadingNotification = MBProgressHUD.showHUDAddedTo(view, animated: true)
    loadingNotification.mode = MBProgressHUDMode.Indeterminate
    loadingNotification.labelText = title
}

func stopLoader(view: UIView) {
    MBProgressHUD.hideAllHUDsForView(view, animated: true)
}

func startCustomLoader(view: UIView) {
    
    let lockerView = UIView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
    let tacLoaderView = LoaderView(frame: CGRectMake(0, -100, 100, 100))
    
    lockerView.backgroundColor = UIColor.redColor()
    lockerView.autoresizesSubviews = true
    
    view.addSubview(lockerView)
    lockerView.addSubview(tacLoaderView)
    
    tacLoaderView.center = view.center
    
    
    tacLoaderView.addStartLoaderAnimation()
}

public func convertToBlackAndWhite(image: UIImage) -> UIImage {
    let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let width = image.size.width
    let height = image.size.height
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
    let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue)
    
    CGContextDrawImage(context, imageRect, image.CGImage)
    let imageRef = CGBitmapContextCreateImage(context)
    let newImage = UIImage(CGImage: imageRef!)
    
    return newImage
}



