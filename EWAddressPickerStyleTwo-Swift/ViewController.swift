//
//  ViewController.swift
//  EWAddressPickerStyleTwo-Swift
//
//  Created by Ethan.Wang on 2019/1/9.
//  Copyright © 2019 Ethan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 30, y: 250, width: ScreenInfo.Width - 60, height: 50))
        label.textAlignment = .center
        label.backgroundColor = UIColor.colorWithRGBA(r: 255, g: 51, b: 102, a: 1)
        return label
    }()
    let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 450, width: ScreenInfo.Width - 200, height: 50))
        button.addTarget(self, action: #selector(onClickSelectButton), for: .touchUpInside)
        button.setTitleColor(UIColor.colorWithRGBA(r: 255, g: 51, b: 102, a: 1), for: .normal)
        button.setTitle("选择地址", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(label)
        self.view.addSubview(button)
    }

    @objc func onClickSelectButton(){
        let addressPicker = EWAddressPickerViewController()
        self.definesPresentationContext = true

        addressPicker.backAddress = { address,province, city, region in
            self.label.text = address
        }
        addressPicker.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        addressPicker.picker.reloadAllComponents()
        self.present(addressPicker, animated: true) {}
    }

}

