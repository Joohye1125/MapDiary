//
//  MapViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/12.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: NMFMapView!
    
    var markerTouchHandler: NMFOverlayTouchHandler = { (overlay) -> Bool in return false}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMarkerTouchHandler()
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
        marker.mapView = mapView
        marker.userInfo = ["location" : "서울특별시청"]
        marker.touchHandler = markerTouchHandler
    }
    
    private func setMarkerTouchHandler() {
        markerTouchHandler = { (overlay) -> Bool in
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let detailVC = mainStoryboard.instantiateViewController(identifier: "DetailItemViewController") as? DetailItemViewController else { return false }
            self.present(detailVC, animated: true, completion: nil)
            
            return true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
