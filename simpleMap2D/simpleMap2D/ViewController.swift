//
//  ViewController.swift
//  simpleMap2D
//
//  Created by Louis Zhou on 6/11/19.
//  Copyright © 2019 Louis Zhou. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true)
    }
    @IBAction func readLocation(_ sender: Any) {
    }
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var movedToUserLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(location: initialLocation)
        
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestWhenInUseAuthorization()
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //    let userArea : MKCoordinateRegion = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
    func searchBarSearchButtonClicked(_ searchBar : UISearchBar){
        print("Search bar clicked")
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                //Remove annotations and overlays
                self.mapReset(self.mapView)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                annotation.title = response?.mapItems.first?.name
                self.mapView.addAnnotation(annotation)
                
                //Create overlay
                let directionRequest = MKDirections.Request()
                directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: self.mapView.userLocation.coordinate))
                directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
                let direction = MKDirections(request: directionRequest)
                direction.calculate(completionHandler: { (response, error) in
                    if let res = response{
                        let route = res.routes.first
                        self.mapView.addOverlay(route!.polyline)
                    }
                })
                
                
                //Zooming in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            
        }
    }
    
    func mapReset(_ mapView: MKMapView){
        let annotations = self.mapView.annotations
        let overlays = self.mapView.overlays
        self.mapView.removeAnnotations(annotations)
        self.mapView.removeOverlays(overlays)
    }
        

    
//    Recenter map
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !movedToUserLocation{
            mapView.region.center = mapView.userLocation.coordinate
            movedToUserLocation = true
        }
    }
    
//    Ask for permission to access location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied,.restricted:
            print("Please modify your location privacy settings")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            manager.startUpdatingLocation()
        }
    }

}

