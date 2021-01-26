//
//  signUpLoginRoundedShadowBtn.swift
//  uber3
//
//  Created by ahmed mostafa on 7/3/20.
//  Copyright © 2020 ahmed mostafa. All rights reserved.
//

import UIKit

class signUpLoginRoundedShadowBtn: UIButton {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize.zero
    }

    

}
