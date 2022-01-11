//
//  MapViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/12.
//

import UIKit
import NMapsMap
import RxSwift

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: NMFMapView!
    
    var markerTouchHandler: NMFOverlayTouchHandler = { (overlay) -> Bool in return false}
    
    let viewModel = MapViewModel()
    
    var mapItems: [NMFMarker] = []
    var disposeBag = DisposeBag()
    
    let MAPITEM_KEY = "mapItem"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DiaryListManager.shared.diaryItemAddSubject
            .subscribe(onNext: addMapItem).disposed(by: disposeBag)
        
        DiaryListManager.shared.diaryItemRemoveSubject
            .subscribe(onNext: removeMapItem).disposed(by: disposeBag)
        
        DiaryListManager.shared.diaryItemUpdateSubject
            .subscribe(onNext: updateMapItem).disposed(by: disposeBag)

        setMarkerTouchHandler()
        
        mapView.clearsContextBeforeDrawing = true
        mapView.liteModeEnabled = true
        mapView.minZoomLevel = 5
        mapView.maxZoomLevel = 13
        mapView.zoomLevel = 6
        
        buildItems()
    }
    
    private func buildItems() {
        let diaryItems = viewModel.diaryItems
        
        for item in diaryItems {
            addMapItem(item: item)
        }
    }
    
    private func addMapItem(item: DiaryItem){
        let mapItem = NMFMarker()
        mapItem.position = NMGLatLng(lat: item.imgMetadata.location.latitude, lng: item.imgMetadata.location.longitude)
        mapItem.mapView = mapView
        mapItem.iconImage = NMFOverlayImage(image: item.image.resize(newWidth: 30))
        mapItem.userInfo = [MAPITEM_KEY : item]
        mapItem.touchHandler = markerTouchHandler
        mapItems.append(mapItem)
    }
    
    private func removeMapItem(item: DiaryItem){
        guard let targetItem = getMapItem(id: item.id) else { return }
     
        targetItem.mapView = nil
        
        if let index = mapItems.firstIndex(of: targetItem) {
            mapItems.remove(at: index)
        }
    }
    
    private func updateMapItem(item: DiaryItem){
        removeMapItem(item: item)
        addMapItem(item: item)
    }
    
    private func getMapItem(id: Int) -> NMFMarker? {
        let targetItem = mapItems.filter{ ($0.userInfo[MAPITEM_KEY] as! DiaryItem).id == id}
        
        // id는 고유하므로 filteredItem의 타입은 array일지라도 1개이다.
        if targetItem.count == 0 || targetItem.count > 1 {
            return nil
        }
        
        return targetItem[0]
    }
    
    private func setMarkerTouchHandler() {
        markerTouchHandler = { (marker) -> Bool in
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let detailVC = mainStoryboard.instantiateViewController(identifier: "DetailItemViewController") as? DetailItemViewController else { return false }
            detailVC.diaryItem = marker.userInfo["mapItem"] as? DiaryItem
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
