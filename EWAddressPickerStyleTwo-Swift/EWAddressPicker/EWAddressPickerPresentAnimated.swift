//
//  EWDataPickerPresentAnimated.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

enum EWAddressPickerPresentAnimateType {
    case present//被推出时
    case dismiss//取消时
}

//EWDatePickerViewController的推出和取消动画
class EWAddressPickerPresentAnimated: NSObject,UIViewControllerAnimatedTransitioning {

    var type: EWAddressPickerPresentAnimateType = .present

    init(type: EWAddressPickerPresentAnimateType) {
        self.type = type
    }
    /// 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    /// 动画效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        switch type {
        case .present:
            guard let toVC = transitionContext.viewController(forKey: .to) as? EWAddressPickerViewController else { return }
            let toView = toVC.view

            let containerView = transitionContext.containerView
            containerView.addSubview(toView!)

            toVC.containV.transform = CGAffineTransform(translationX: 0, y: (toVC.containV.frame.height))

            UIView.animate(withDuration: 0.25, animations: {
                /// 背景变色
                toVC.backgroundView.alpha = 1.0
                /// datepicker向上推出
                toVC.containV.transform =  CGAffineTransform(translationX: 0, y: -10)
            }) { ( _ ) in
                UIView.animate(withDuration: 0.2, animations: {
                    /// transform初始化
                    toVC.containV.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    transitionContext.completeTransition(true)
                })
            }
        case .dismiss:
            guard let fromVC = transitionContext.viewController(forKey: .from) as? EWAddressPickerViewController else { return }

            UIView.animate(withDuration: 0.25, animations: {
                fromVC.backgroundView.alpha = 0.0
                /// datepicker向下推回
                fromVC.containV.transform =  CGAffineTransform(translationX: 0, y: (fromVC.containV.frame.height))
            }) { ( _ ) in
                transitionContext.completeTransition(true)
            }
        }
    }
}
