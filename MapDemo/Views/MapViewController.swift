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
    
    var mapView =  GMSMapView()
    var locationManager = CLLocationManager()
    var marker = GMSMarker()
    
    /// 目的地
    var desPosition = CLLocationCoordinate2D()
    
    override func loadView() {
        super.loadView()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        //        mapView.cameraMode = .free
        
        self.view = mapView
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        
        // Show the terms and conditions.
        makeButton()
    }
    
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
    
    // Create a route and start guidance.
    //    @objc func startNav() {
    //        var destinations = [GMSNavigationWaypoint]()
    //
    //        if let tapPoint = GMSNavigationWaypoint(location: desPosition, title: ""){
    //            destinations.append(tapPoint)
    //        }
    //
    //        mapView.navigator?.setDestinations(
    //            destinations
    //        ) { routeStatus in
    //            print("Handle route statuses \(routeStatus)")
    //            guard routeStatus == .OK else {
    //                print("Handle route statuses that are not OK.")
    //                return
    //            }
    //            self.mapView.navigator?.isGuidanceActive = true
    //            self.mapView.locationSimulator?.simulateLocationsAlongExistingRoute()
    //            self.mapView.cameraMode = .following
    //            self.mapView.travelMode = .cycling
    //        }
    //    }
    
    // Add a button to the view.
    func makeButton() {
        // A button to start navigation.
        let navButton = UIButton(frame: CGRect(x: 5, y: 150, width: 200, height: 35))
        navButton.backgroundColor = .blue
        navButton.alpha = 0.5
        navButton.setTitle("Start navigation", for: .normal)
        navButton.addTarget(self, action: #selector(startNav), for: .touchUpInside)
        self.mapView.addSubview(navButton)
    }
    
    @objc func startNav() {
        acceptTerms()
        
        getDirections()
        self.mapView.cameraMode = .following
        self.mapView.travelMode = .cycling
        self.mapView.navigator?.isGuidanceActive = true
    }
    
    func getDirections() {
        guard let currentLocation = locationManager.location?.coordinate else {
            return
        }
        
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        let destination = "\(desPosition.latitude),\(desPosition.longitude)"
        
        let apiKey = SDKConstants.apiKey
        let apiUrl = "https://maps.googleapis.com/maps/api/directions/json?" +
        "origin=\(origin)&destination=\(destination)&key=\(apiKey)&mode=walking"
        
        AF.request(apiUrl).response { response in
            if let result = response.value {
                let json = JSON(result as Any)
                print(json)
                // 解析 Directions API 响应
                let route = json["routes"][0]["overview_polyline"]["points"].stringValue
                self.showPath(polyline: route)
            }
        }
    }
    
    // 在地图上显示路径
    func showPath(polyline: String) {
        let path = GMSPath(fromEncodedPath: polyline)
        let line = GMSPolyline(path: path)
        line.strokeWidth = 4.0
        line.map = mapView
    }
}

extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!,
                                              longitude: (location?.coordinate.longitude)!,
                                              zoom: 16.0)
        self.mapView.animate(to: camera)
        print("123")
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
}

extension MapViewController:GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
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
