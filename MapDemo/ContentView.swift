//
//  ContentView.swift
//  MapDemo
//
//  Created by dooahu on 2023/12/5.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            MapViewControllerBridge()
            
            VStack{
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("开始出发")
                        .foregroundStyle(.white)
                })
                .buttonStyle(.bordered)
                .background(.red.opacity(0.7))
                .padding(EdgeInsets(top: 0,
                                    leading: 10,
                                    bottom: 30,
                                    trailing: 10))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
