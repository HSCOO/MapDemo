// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  MapViewController.swift
//  GoogleMapsSwiftUI
//
//  Created by Chris Arriola on 2/5/21.
//

import GoogleMaps
import Alamofire
import SwiftyJSON
import GoogleNavigation

import SwiftUI
import UIKit

class MapViewController: UIViewController {
    /// 导航状态
    var navigationModel: NavigationModel
    
    /// 谷歌地图
    lazy var mapView:GMSMapView = {
        let mapView =  GMSMapView()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        return mapView
    }()
    
    /// 位置管理
    lazy var locationManager:CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.delegate = self
        
        return locManager
    }()
    
    /// 大头针
    var marker = GMSMarker()
    
    /// 开始位置
    var startLocation: CLLocation?
    
    /// 目的地
    var desPosition:CLLocationCoordinate2D?
    
    init(navigationModel: NavigationModel) {
        self.navigationModel = navigationModel
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(environmentObjectDidChange),
                                               name: NavigationModel.StatusDidChangeNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: NavigationModel.StatusDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentLocation = locationManager.location?.coordinate else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation.latitude),
                                              longitude: (currentLocation.longitude),
                                              zoom: 16.0)
        self.mapView.animate(to: camera)
    }
    
    @objc func environmentObjectDidChange(notif:Notification) {
        print("Environment object changed \(notif)")
        guard let navigationStatus = notif.object as? NavigationStatus else { return}
        switch navigationStatus {
            case .started:
                startNav()
            case .error:
                print("发生错误")
            case .finished:
                print("完成导航")
                mapView.clear()
                desPosition = nil
            case .normal:
                print("正常状态")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = mapView
        locationManager.startUpdatingLocation()
    }
}

// MARK: 导航路径
extension MapViewController{
    
    /// 开始导航
    func startNav() {
        if desPosition == nil{
            navigationModel.status = .normal
            navigationModel.tipMsg = "还没选择目的地"
            return
        }
        
        acceptTerms()
        getDirections()
        self.mapView.cameraMode = .following
        self.mapView.travelMode = .cycling
        self.mapView.navigator?.isGuidanceActive = true
    }
    
    /// 同意导航协议
    func acceptTerms() {
        let companyName = "VEO Co."
        
        GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(
            withCompanyName: companyName) { termsAccepted in
                if termsAccepted {
                    // Enable navigation if the user accepts the terms.
                    self.mapView.isNavigationEnabled = true
                    
                    // Request authorization to use location services.
                    self.locationManager.requestAlwaysAuthorization()
                    
                    // Request authorization for alert notifications which deliver guidance instructions
                    // in the background.
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
                        granted, error in
                        // Handle rejection of notification authorization.
                        if !granted || error != nil {
                            print("Authorization to deliver notifications was rejected.")
                        }
                    }
                } else {
                    // Handle rejection of terms and conditions.
                }
            }
    }
    
    /// 请求路线规划
    func getDirections() {
        guard let currentLocation = locationManager.location?.coordinate,
              let desLocation = desPosition else {
            return
        }
        
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(desLocation.latitude),\(desLocation.longitude)"
        
        let apiKey = SDKConstants.apiKey
        let apiUrl = "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=\(origin)&destination=\(destination)&key=\(apiKey)&mode=walking"
        
        AF.request(apiUrl).response { response in
            if let result = response.value {
                let json = JSON(result as Any)
                let route = json["routes"][0]["overview_polyline"]["points"].stringValue
                self.showPath(polyline: route)
            }
        }
    }
    
    /// 在地图上显示路径
    func showPath(polyline: String) {
        let path = GMSPath(fromEncodedPath: polyline)
        let line = GMSPolyline(path: path)
        line.strokeWidth = 4.0
        line.map = mapView
    }
}

extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard navigationModel.status == .started else {
            return
        }
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!,
                                              longitude: (location?.coordinate.longitude)!,
                                              zoom: 17.0)
        self.mapView.animate(to: camera)
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let latestLocation = locations.last {
            let distance = startLocation?.distance(from: latestLocation) ?? 0.0
            print("Distance traveled: \(distance) meters")
            navigationModel.distance += Int(distance)
            startLocation = latestLocation
        }
        
        if let gPSSignalStrength = location?.getGPSSignalStrength(){
            navigationModel.gPSSignalStrength = gPSSignalStrength
        }
        //Finally stop updating location otherwise it will come again and again in this delegate
    }
}

extension MapViewController:GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard navigationModel.status == .normal  ||
        navigationModel.status == .finished else {
            navigationModel.tipMsg = "可以结束后再更换地址"
            return
        }
        mapView.clear()
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.marker.position = position
            self.marker.map = mapView
            self.marker.title = "tap location"
            
            self.desPosition = position
            print("New Marker Lat Long - ",coordinate.latitude, coordinate.longitude)
        }
    }
}
