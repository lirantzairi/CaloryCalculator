//
//  Weak.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/17/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import Foundation

class Weak<T: AnyObject>
{
    weak var value : T?
    init (value: T)
    {
        self.value = value
    }
}
