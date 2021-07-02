//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: - Outlets & Variables
    @IBOutlet weak var titleLabel: UILabel!

    var n = 0.0
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = ""
        for letter in K.appName {
            n += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * n) {
                self.titleLabel.text?.append(letter)
            }
        }
    }
    
    //MARK: - View Will Dissapepear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
