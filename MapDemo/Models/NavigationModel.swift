//
//  NavigationModel.swift
//  MapDemo
//
//  Created by dooahu on 2023/12/6.
//

import Foundation
import SwiftUI


/// 导航状态
enum NavigationStatus {
    
    case normal
    // 已经开始
    case started
    // 已经结束
    case finished
    // 错误状态
    case error
}

class NavigationModel: ObservableObject{
    static let StatusDidChangeNotification = Notification.Name("StatusDidChange")
    
    /// 当前的导航状态
    @Published var status:NavigationStatus = .normal{
        didSet {
            NotificationCenter.default.post(name: NavigationModel.StatusDidChangeNotification, object: status)
        }
    }
    
    /// 当前行驶的距离
    @Published var distance:Int = 0
    
    /// 当前的信号强度
    /// 默认信号强
    @Published var gPSSignalStrength: GPSSignalStrength = .strong(horizontalAccuracy: 0)
    
    /// 提示信息
    @Published var tipMsg: String = ""
}
