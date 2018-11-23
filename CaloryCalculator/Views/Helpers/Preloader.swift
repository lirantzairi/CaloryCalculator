//
//  Preloader.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/18/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class Preloader: NSObject
{
    static private var view: UIView?
    
    class func show()
    {
        if Preloader.view != nil
        {
            return
        }
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.center = view.center
        activityIndicatorView.hidesWhenStopped = false
        activityIndicatorView.startAnimating()
        
        view.addSubview(activityIndicatorView)
        UIApplication.shared.keyWindow?.addSubview(view)
        
        Preloader.view = view
    }
    
    class func hide()
    {
        guard let view = Preloader.view else
        {
            return
        }
        
        view.removeFromSuperview()
        Preloader.view = nil
    }
}
