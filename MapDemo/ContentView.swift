//
//  ContentView.swift
//  MapDemo
//
//  Created by dooahu on 2023/12/5.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @State private var totalTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var totalDuration = 0
    @State private var totalDurationDisplay = ""
    
    @State var toastMsgCenter = ""
    @State var showToastMsgCenter = false
    
    let alertInfo = AlertToastInfo()
        
    var body: some View {
        ZStack{
            MapViewControllerBridge()
            
            VStack{
                navigationModel.status == .started ?
                VStack(alignment: .leading,spacing: 20){
                    Text("耗时：\(totalDurationDisplay)")
                    Text("距离：\(navigationModel.distance) m")
                    Text("GPS信号：\(navigationModel.gPSSignalStrength.displayStatus())")
                }
                .background(.green.opacity(0.4))
                .padding(EdgeInsets(top: 30,
                                    leading: 10,
                                    bottom: 0,
                                    trailing: 10)) : nil
                Spacer()
                Button(action: {
                    switch navigationModel.status {
                    case .normal:
                        navigationModel.status = .started
                        totalTimerStart()
                        resetStatus()
                    case .started:
                        navigationModel.status = .finished
                        totalTimerFinish()
                    case .finished:
                        navigationModel.status = .started
                        totalTimerStart()
                    case .error:
                        totalTimerFinish()
                        resetStatus()
                        print("重新开始")
                    }
                    
                }, label: {
                    switch navigationModel.status {
                    case .normal:
                        Text("开始出发")
                            .foregroundStyle(.white)
                    case .started:
                        Text("结束")
                            .foregroundStyle(.white)
                    case .finished:
                        Text("开始出发")
                            .foregroundStyle(.white)
                    case .error:
                        Text("重新开始")
                            .foregroundStyle(.white)
                    }
                })
                .buttonStyle(.bordered)
                .background(.red.opacity(0.7))
                .padding(EdgeInsets(top: 0,
                                    leading: 10,
                                    bottom: 30,
                                    trailing: 10))
            }
        }
        .onReceive(totalTimer, perform: { _ in
            totalTimerEventHandle()
        })
        .onReceive(navigationModel.$status, perform: { curStatus in
            switch curStatus {
                case .error:
                    print("发生错误")
                    totalTimerFinish()
                    resetStatus()
                    navigationModel.status = .normal
                case .finished:
                    print("完成导航")
                alertInfo.show(title: "完成导航", msg: "耗时：\(totalDurationDisplay)\n已经行走：\(navigationModel.distance) m\nGPS信号：\(navigationModel.gPSSignalStrength.displayStatus())"){
                    resetStatus()
                }
                case .normal:
                    print("正常状态")
                default: break
                
            }
        })
        .onReceive(navigationModel.$tipMsg, perform: { tipMsg in
            toastMsgCenter = tipMsg
            showToastMsgCenter = true
        })
        .toast(message: $toastMsgCenter,
               isShowing: $showToastMsgCenter,
               config: Toast.Config(duration: 2, alignment: .center))
    }
    
    func resetStatus(){
        toastMsgCenter = ""
        showToastMsgCenter = false
        navigationModel.distance = 0
        
        totalDuration = 0
        totalDurationDisplay = ""
    }
}

// MARK: 定时器
extension ContentView{
    func totalTimerEventHandle() {
        guard navigationModel.status == .started else{ return }
        
        totalDuration += 1
        totalDurationDisplay = "\(totalDuration)s"
    }
    
    func totalTimerStart() {
        totalDuration = 0
        totalDurationDisplay = ""
        totalTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func totalTimerFinish() {
        totalTimer.upstream.connect().cancel()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationModel())
    }
}
