//
//  ViewController.swift
//  Assignment_1
//  Created by Mister on 15/05/2021.
//

import UIKit
import MapKit
import CoreLocation


struct Place {
  var name: String
  var lattitude: CLLocationDegrees
  var longtitude: CLLocationDegrees
}

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var makeRouteButton: UIButton!

    let locationManager = CLLocationManager()
    var currentLocatonCordinates = CLLocationCoordinate2D()
    var pointPin: Int = 0
    
    let places = [Place(name:"A", lattitude:43.6995524, longtitude:-79.4821026),Place(name:"B", lattitude:43.589940, longtitude:-79.632852),Place(name:"C", lattitude:43.734733, longtitude:-79.755662)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeRouteButton.isHidden = true
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }

            map.delegate = self
            map.mapType = .standard
            map.isZoomEnabled = true
            map.isScrollEnabled = true

            if let coor = map.userLocation.location?.coordinate{
                map.setCenter(coor, animated: true)
            }
        
        let k_longPress = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
                          map.addGestureRecognizer(k_longPress)
    }
    
    // MARK:- LOCATION MANAGER DELEGATE
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
            self.map.setRegion(region, animated: true)
            self.currentLocatonCordinates.latitude = location.coordinate.latitude
            self.currentLocatonCordinates.latitude = location.coordinate.longitude
            self.locationManager.stopUpdatingLocation()
         }
     }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(sender: UILongPressGestureRecognizer) {
                
        if (sender.state == UIGestureRecognizer.State.ended)
        {
            
            if pointPin < 3 {
            let cordinate = CLLocationCoordinate2D.init(latitude:places[pointPin].lattitude, longitude: places[pointPin].longtitude)
            let annotation = MKPointAnnotation()
            annotation.title = places[pointPin].name
            annotation.subtitle = "The Distance of \(places[pointPin].name) is \(calculateDistancefromCurrentLocation(location1: cordinate, location2: self.currentLocatonCordinates)) from user's location"
            annotation.coordinate = cordinate
            map.addAnnotation(annotation)
                
            let center = CLLocationCoordinate2D(latitude: cordinate.latitude, longitude: cordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50))
            self.map.setRegion(region, animated: true)
            if pointPin == 2
                {
                  addPolyline()
                }
            pointPin += 1
            }
            else
            {
                self.pointPin = 0
                self.removeAllMarkers()
                let cordinate = CLLocationCoordinate2D.init(latitude:places[pointPin].lattitude, longitude: places[pointPin].longtitude)
                let annotation = MKPointAnnotation()
                annotation.title = places[pointPin].name
                annotation.subtitle = "The Distance of \(places[pointPin].name) is \(calculateDistancefromCurrentLocation(location1: cordinate, location2: self.currentLocatonCordinates)) from user's location"
                annotation.coordinate = cordinate
                map.addAnnotation(annotation)
                    
                let center = CLLocationCoordinate2D(latitude: cordinate.latitude, longitude: cordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50))
                self.map.setRegion(region, animated: true)
                pointPin += 1
            }
        }
        if (sender.state == UIGestureRecognizer.State.began)
        {

        }
    }
func addPolyline() {
        let coordinates = [CLLocationCoordinate2D.init(latitude:places[0].lattitude, longitude:places[0].longtitude),CLLocationCoordinate2D.init(latitude:places[1].lattitude, longitude:places[1].longtitude),CLLocationCoordinate2D.init(latitude:places[2].lattitude, longitude:places[2].longtitude),CLLocationCoordinate2D.init(latitude:places[0].lattitude, longitude:places[0].longtitude)]
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            map.addOverlay(polyline)
        self.addPolygon()
    }
    
    func addPolygon() {
            
        self.makeRouteButton.isHidden = false
        let coordinates = [CLLocationCoordinate2D.init(latitude:places[0].lattitude, longitude:places[0].longtitude),CLLocationCoordinate2D.init(latitude:places[1].lattitude, longitude:places[1].longtitude),CLLocationCoordinate2D.init(latitude:places[2].lattitude, longitude:places[2].longtitude),CLLocationCoordinate2D.init(latitude:places[0].lattitude, longitude:places[0].longtitude)]
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            map.addOverlay(polygon)
    }
    
    func removeAllMarkers()
    {
        self.makeRouteButton.isHidden = true
        removePin()
        removeOverlays()
    }
   
    //MARK: - remove pin from map
    func removePin() {
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }
    
    //MARK: - remove Overlays from map
    func removeOverlays() {
        for overlay in map.overlays
        {
            map.removeOverlay(overlay)
        }
    }
    
    //MARK: - draw route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        map.removeOverlays(map.overlays)
        removePin()
        pointPin = 0
        self.addPinsforRoute()

        for place in places{
            
            let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D.init(latitude:places[0].lattitude, longitude:places[0].longtitude))
            let destinationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D.init(latitude:place.lattitude, longitude:place.longtitude))
            
            // request a direction
            let directionRequest = MKDirections.Request()
            
            // assign the source and destination properties of the request
            directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
            directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
            
            // transportation type
            directionRequest.transportType = .automobile
            
            // calculate the directiondd
            let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                guard let directionResponse = response else {return}
                // create the route
                let route = directionResponse.routes[0]
                // drawing a polyline
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                // define the bounding map rect
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
               }
         }
    }
    
    func addPinsforRoute()
    {
        for place in places{
            print(place)
            if pointPin < 3 {
            let cordinate = CLLocationCoordinate2D.init(latitude:places[pointPin].lattitude, longitude: places[pointPin].longtitude)
            let annotation = MKPointAnnotation()
            annotation.title = places[pointPin].name
            annotation.subtitle = "The Distance of \(places[pointPin].name) is \(calculateDistancefromCurrentLocation(location1: cordinate, location2: self.currentLocatonCordinates)) from user's location"
            annotation.coordinate = cordinate
            map.addAnnotation(annotation)
                
            let center = CLLocationCoordinate2D(latitude: cordinate.latitude, longitude: cordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50))
            self.map.setRegion(region, animated: true)
            pointPin += 1
            }
        }
    }
      
    //MARK: - Calculate Distance from User's Current Location in KM

    func calculateDistancefromCurrentLocation(location1:CLLocationCoordinate2D,location2:CLLocationCoordinate2D) -> String
    {
        
        let myLocation = CLLocation(latitude:location2.latitude, longitude: location2.longitude)
        let myBuddysLocation = CLLocation(latitude:location1.latitude, longitude: location1.longitude)
        let distance = myLocation.distance(from: myBuddysLocation) / 1000
        return (String(format: " is %.01fkm", distance))
    }
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }

        switch annotation.title {
        case "A":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
          //  annotationView.image = UIImage(named: "ic_place_a")
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            return annotationView
        case "B":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
          //  annotationView.image = UIImage(named: "ic_place_b")
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            return annotationView
        case "C":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
           // annotationView.image = UIImage(named: "ic_place_c")
            annotationView.canShowCallout = true
           // annotationView.animatesDrop = true
            return annotationView
        default:
            return nil
        }
    }

    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.red
            rendrer.lineWidth = 0.5
            return rendrer
        }
        return MKOverlayRenderer()
    }
}

