//
//  EWDatePickerViewController.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class EWAddressPickerViewController: UIViewController {

    class Province {
        var name: String!
        var id: Int!
        var cityModelArr: [City] = []
    }

    class City {
        var name: String!
        var id: Int!
        var regionModelArr: [Region] = []
    }

    class Region {
        var name: String!
        var id: Int!
    }

    var backAddress: ((String,String,String,String?)->())?

    /// 数据源初始化
    var dataDict: [String: Any]?
    /// 省字典
    var provincesArr: [String]?
    /// 省ID字典
    var provinceIDDict: [String: Int]?
    /// 城市字典
    var citysDict: [String: Any]?
    /// 城市ID字典
    var cityIDDict: [String: Int]?
    /// 地区字典
    var regionsDict: [String: Any]?
    /// 地区ID字典
    var regionIDDict: [String: Int]?
    /// 整体数据源
    var provinceModelArr: [Province] = []

    var containV:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: ScreenInfo.Height - 300, width: ScreenInfo.Width, height: 310))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        return view
    }()
    var backgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return view
    }()
    var picker: UIPickerView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAddressData()
        drawMyView()
    }
    //MARK: - Func
    private func drawMyView(){
        self.view.backgroundColor = UIColor.clear
        self.view.insertSubview(self.backgroundView, at: 0)
        self.modalPresentationStyle = .custom//viewcontroller弹出后之前控制器页面不隐藏 .custom代表自定义

        let titleLabel = UILabel(frame: CGRect(x: 100, y: 13, width: ScreenInfo.Width-200, height: 24))
        titleLabel.textColor = UIColor.colorWithRGBA(r: 51, g: 51, b: 51, a: 1)
        titleLabel.text = "选择国家地区"
        titleLabel.textAlignment = .center

        let cancel = UIButton(frame: CGRect(x: 10, y: 13, width: 24, height: 24))
        let sure = UIButton(frame: CGRect(x: ScreenInfo.Width - 50, y: 13, width: 40, height: 24))
        cancel.setTitle("取消", for: .normal)
        cancel.setImage(UIImage(named: "baseVC_cancel"), for: .normal)
        sure.setTitle("确认", for: .normal)
        sure.titleLabel?.textAlignment = .right
        sure.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sure.setTitleColor(UIColor.colorWithRGBA(r: 255, g: 51, b: 102, a: 1), for: .normal)
 
        cancel.addTarget(self, action: #selector(self.onClickCancel), for: .touchUpInside)
        sure.addTarget(self, action: #selector(self.onClickSure), for: .touchUpInside)
        picker = UIPickerView(frame: CGRect(x: 0, y: 30, width: ScreenInfo.Width, height: 266))
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.clear
        picker.clipsToBounds = true//如果子视图的范围超出了父视图的边界，那么超出的部分就会被裁剪掉。
        //创建日期选择器
        self.containV.addSubview(titleLabel)
        self.containV.addSubview(cancel)
        self.containV.addSubview(sure)
        self.containV.addSubview(picker)
        self.view.addSubview(self.containV)

        self.transitioningDelegate = self as UIViewControllerTransitioningDelegate//自定义转场动画
    }

    //MARK: onClick
    @objc func onClickCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func onClickSure() {
        let selectP = picker.selectedRow(inComponent: 0)
        var selectC = picker.selectedRow(inComponent: 1)
        var selectR = picker.selectedRow(inComponent: 2)
        let p = provinceModelArr[selectP]
        if selectC > p.cityModelArr.count - 1 {
            selectC = p.cityModelArr.count - 1
        }
        let c = p.cityModelArr[selectC]
        if selectR > c.regionModelArr.count - 1 {
            selectR = c.regionModelArr.count - 1
        }
        var rStr: String? = nil
        if c.regionModelArr.count > 1 {
            let r = c.regionModelArr[selectR]
            rStr = r.name
        }
        var address: String = ""
        if rStr == nil{
            if p.name == c.name {
                address = p.name
            }
        }else {
            if p.name == "海外"{
                address = rStr!
            } else {
                address = p.name + c.name + rStr!
            }
        }
        if self.backAddress != nil {
            self.backAddress!(address, p.name,c.name,rStr)
        }
        self.dismiss(animated: true, completion: nil)
    }
    ///点击任意位置view消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let currentPoint = touches.first?.location(in: self.view)
        if !self.containV.frame.contains(currentPoint ?? CGPoint()) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: - 加载数据源
    private func loadAddressData() {
        let filePath = Bundle.main.path(forResource: "address", ofType: "json")
        if filePath == nil {
            print("加载数据源失败，请检查文件路径")
            return
        }
        var addressStr: String? = nil
        do {
            addressStr = try String.init(contentsOfFile: filePath!, encoding: .utf8)
        } catch {
            print("encoding error = ",error)
            return
        }
        dataDict = dictionaryWith(jsonString: addressStr)
        if dataDict == nil { return }

        provincesArr = dataDict!["province"] as! [String]?
        citysDict = dataDict!["city"] as! [String : Any]?
        regionsDict = dataDict!["region"] as! [String : Any]?

        if provincesArr == nil || citysDict == nil  || regionsDict == nil { return }

        provinceIDDict = dataDict!["provinceID"] as! [String: Int]?
        cityIDDict = dataDict!["cityID"] as! [String: Int]?
        regionIDDict = dataDict!["regionID"] as! [String: Int]?

        if provinceIDDict == nil || cityIDDict == nil || regionIDDict == nil { return }

        let provinceCount = provincesArr!.count
        for i in 0..<provinceCount {
            let pName = provincesArr![i]
            let citys = citysDict![pName] as! [String]
            let p = Province()
            p.name = pName
            p.id = provinceIDDict![pName]

            var cityModels: [City] = []
            for cityName in citys {
                let regionArr = regionsDict![cityName] as! [String]
                let cityModel = City()
                cityModel.id = cityIDDict![cityName]
                cityModel.name = cityName

                var regionModels: [Region] = []
                for regionName in regionArr {
                    let regionModel = Region()
                    regionModel.name = regionName
                    regionModel.id = regionIDDict![regionName]
                    regionModels.append(regionModel)
                }
                cityModel.regionModelArr = regionModels
                cityModels.append(cityModel)
            }
            p.cityModelArr = cityModels
            provinceModelArr.append(p)
        }
    }

    private func dictionaryWith(jsonString: String?) -> [String: Any]? {
        var dic: [String: Any]? = nil
        if jsonString != nil {
            let jsonData = jsonString!.data(using: .utf8)
            if jsonData != nil {
                do {
                    let dicc = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
                    dic = dicc as? [String: Any]
                } catch {
                    print("json error:",error)
                }
            }
        }
        return dic
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
//MARK: - PickerViewDelegate
extension EWAddressPickerViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return provinceModelArr[row].name
        case 1:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let p = provinceModelArr[selectP]
            if row > p.cityModelArr.count - 1 {
                return nil
            }
            return p.cityModelArr[row].name
        case 2:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let selectC = pickerView.selectedRow(inComponent: 1)
            let p = provinceModelArr[selectP]
            if selectC > p.cityModelArr.count - 1 {
                return nil
            }
            let c = p.cityModelArr[selectC]
            if row > c.regionModelArr.count - 1 {
                return nil
            }
            return c.regionModelArr[row].name
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            let selectC = pickerView.selectedRow(inComponent: 1)
            let selectR = pickerView.selectedRow(inComponent: 2)
            pickerView.reloadComponent(1)
            pickerView.selectRow(selectC, inComponent: 1, animated: true)
            pickerView.reloadComponent(2)
            pickerView.selectRow(selectR, inComponent: 2, animated: true)
            break
        case 1:
            let selectR = pickerView.selectedRow(inComponent: 2)
            pickerView.reloadComponent(2)
            pickerView.selectRow(selectR, inComponent: 2, animated: true)
            break
        default:
            break
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
            label?.adjustsFontSizeToFitWidth = true
            label?.textAlignment = .center
            label?.font = UIFont.systemFont(ofSize: 15)
        }
        label?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return label!
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return provinceModelArr.count
        case 1:
            let selectP = pickerView.selectedRow(inComponent: 0)
            return provinceModelArr[selectP].cityModelArr.count
        case 2:
            let selectP = pickerView.selectedRow(inComponent: 0)
            let selectC = pickerView.selectedRow(inComponent: 1)
            let p = provinceModelArr[selectP]
            if selectC > p.cityModelArr.count - 1 {
                return 0
            }
            return p.cityModelArr[selectC].regionModelArr.count
        default:
            return 0
        }
    }
}
//MARK: - 转场动画delegate
extension EWAddressPickerViewController:UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = EWAddressPickerPresentAnimated(type: .present)
        return animated
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = EWAddressPickerPresentAnimated(type: .dismiss)
        return animated
    }
}

