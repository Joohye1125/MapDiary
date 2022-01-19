//
//  DetailItemUpdateViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/21.
//

import UIKit
import Photos

class DetailItemUpdateViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var contentsView: UITextView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
  
    var diaryItem: DiaryItem?
    var imageMetadata = ImageMetadata(imageDate: nil, location: GPS(latitude: -190, longitude: -190))
    
    let imagePicker = UIImagePickerController()
    let viewModel = DiaryListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initImagePicker()
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPhotoLibrary)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        self.title = "수정하기"
        
        guard let item = diaryItem else {return}
        
        imageView.image = item.image
        titleField.text = item.title
        contentsView.text = item.contents
        imageMetadata = item.imgMetadata
    }
    
    private func initImagePicker() {
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = false // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
    }
    
    @objc private func showPhotoLibrary() {
        self.present(self.imagePicker, animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        guard let item = diaryItem else {return}
        
        guard let image = imageView.image?.downSample(scale: 1) else {return}
        guard let title = titleField.text else {return}
        guard let contents = contentsView.text else {return}
        
        item.image = image
        item.title = title
        item.contents = contents
        item.imgMetadata = imageMetadata
        
        viewModel.update(item: item)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension DetailItemUpdateViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
        
        DispatchQueue.main.async {
            guard let asset = info[.phAsset] as? PHAsset else { return }
            
            self.imageMetadata.imageDateTime = asset.creationDate ?? nil
            
            guard let latitude = asset.location?.coordinate.latitude,
                    let longitude = asset.location?.coordinate.longitude else {
                        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
                        
                        let alertController = UIAlertController(title: "사진에서 위치 정보를 가져올 수 없습니다.", message: "", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: false, completion: nil)
                        return
                    }
            
            self.imageMetadata.location = GPS(latitude: latitude, longitude: longitude)
            
            self.imageView.image = newImage?.downSample(scale: 1) // 받아온 이미지를 update
            picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        }
    }
}

