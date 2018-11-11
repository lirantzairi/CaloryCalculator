//
//  ViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/10/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController
{

    var ref: DatabaseReference!
    var count = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    @IBAction func button1(_ sender: UIButton)
    {
        let newRef = ref.child("users/kuku" + String(count))
        newRef.setValue("")
        count += 1
    }
    
    @IBAction func button2(_ sender: UIButton)
    {
    }
    
    @IBAction func button3(_ sender: UIButton)
    {
    }
    

}

