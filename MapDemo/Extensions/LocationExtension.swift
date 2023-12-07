//
//  LocationExtension.swift
//  MapDemo
//
//  Created by dooahu on 2023/12/6.
//

import Foundation
import CoreLocation

/// 信号强度
enum GPSSignalStrength{
    case normal(horizontalAccuracy:Int)
    case none(horizontalAccuracy:Int)
    case weak(horizontalAccuracy:Int)
    case strong(horizontalAccuracy:Int)
    
    func displayStatus() -> String {
        switch self {
        case .normal(horizontalAccuracy: let val):
            return "信号一般，水平精度:\(val)"
        case .none(horizontalAccuracy: let val):
            return "信号无，水平精度:\(val)"
        case .weak(horizontalAccuracy: let val):
            return "信号弱，水平精度:\(val)"
        case .strong(horizontalAccuracy: let val):
            return "信号强，水平精度:\(val)"
        }
    }
}

extension CLLocation{
    
    /// 获取信号强度
    /// 只判断了位置的水平精度
    /// < 0, 没有信号
    /// > 143, 信号弱
    /// [48, 143), 信号一般
    /// [0, 48), 信号强
    /// - Parameter location: 当前的位置信息
    /// - Returns: 强度枚举信息
    func getGPSSignalStrength() -> GPSSignalStrength{
        let horizontalAccuracy = self.horizontalAccuracy
        if horizontalAccuracy < 0{
            return GPSSignalStrength.none(horizontalAccuracy: Int(horizontalAccuracy))
        }else if horizontalAccuracy > 143{
            return GPSSignalStrength.weak(horizontalAccuracy: Int(horizontalAccuracy))
        }else if horizontalAccuracy > 48{
            return GPSSignalStrength.normal(horizontalAccuracy: Int(horizontalAccuracy))
        }else {
            return GPSSignalStrength.strong(horizontalAccuracy: Int(horizontalAccuracy))
        }
    }
}
