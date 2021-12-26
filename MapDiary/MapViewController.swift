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
    
    let viewModel = MapViewModel()
    
    var mapItems: [NMFMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMarkerTouchHandler()
        
        mapView.clearsContextBeforeDrawing = true
        mapView.liteModeEnabled = true
        mapView.minZoomLevel = 5
        mapView.maxZoomLevel = 13
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.zoomLevel = 6
        buildItems()
    }
    
    private func buildItems() {
        mapItems.removeAll()
    
        let diaryItems = viewModel.diaryItems
        
        for item in diaryItems {
            let mapItem = NMFMarker()
            guard let latitude = item.imgMetadata.location?.latitude, let longitude = item.imgMetadata.location?.longitude else { continue }
            mapItem.position = NMGLatLng(lat: latitude, lng: longitude)
            mapItem.mapView = mapView
            mapItem.iconImage = NMFOverlayImage(image: item.image.resize(newWidth: 50))
            mapItem.userInfo = ["mapItem" : item]
            mapItem.touchHandler = markerTouchHandler
            mapItems.append(mapItem)
        }
    }
    
    private func setMarkerTouchHandler() {
        markerTouchHandler = { (marker) -> Bool in
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let detailVC = mainStoryboard.instantiateViewController(identifier: "DetailItemViewController") as? DetailItemViewController else { return false }
            detailVC.diaryItem = marker.userInfo["mapItem"] as! DiaryItem
            self.navigationController?.pushViewController(detailVC, animated: true)
            return true
        }
    }
    
}

class MapViewModel {
    
    private let manager = DiaryListManager.shared
    
    var diaryItems: [DiaryItem] {
        return manager.diaryItems
    }
    
    var sortedList: [DiaryItem] {
        let sortedList = manager.diaryItems.sorted { prev, next  in
            return prev.date > next.date
        }
        
        return sortedList
    }
   
    func diaryItem(at index: Int) -> DiaryItem {
        return sortedList[index]
    }
   
}
