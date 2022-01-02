//
//  CreateViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/12.
//

import UIKit
import Photos

class CreateViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var imageMetadata = ImageMetadata(location: GPS(latitude: -190, longitude: -190))
    
    let textViewPlaceHolder = "내용을 입력해주세요"
    let viewModel = CreateViewModel()
    let imagePicker = UIImagePickerController()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initImagePicker()
        placeholderSetting()
        checkPhotoLibraryAuth()
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPhotoLibrary)))
    }
    
    private func initImagePicker() {
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = false // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
    }
    
    private func checkPhotoLibraryAuth() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status != .authorized {
                    print("authorisation not granted!")
                }
            }
        }
    }
    
    @objc private func showPhotoLibrary() {
        self.present(self.imagePicker, animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        
        guard let image = imageView.image else {return}
        guard let title = titleTextField.text else {return}
        guard let contents = textView.text else {return}
        
        let item = DiaryListManager.shared.createItem(image: image, title: title, contents: contents, metadata: imageMetadata)
        viewModel.add(item)
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreateViewController: UIImagePickerControllerDelegate, URLSessionDelegate {
    
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
                        let alertController = UIAlertController(title: "사진에서 위치 정보를 가져올 수 없습니다.", message: "", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: false, completion: nil)
                        return
                    }
            
            self.imageMetadata.location = GPS(latitude: latitude, longitude: longitude)
            
            self.imageView.image = newImage // 받아온 이미지를 update
            picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
        }
        
    }
}

extension CreateViewController: UITextViewDelegate {
    func placeholderSetting() {
        textView.delegate = self // txtvReview가 유저가 선언한 outlet
        textView.text = textViewPlaceHolder
        textView.textColor = UIColor.lightGray
        
    }
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
           textView.text = nil
           textView.textColor = UIColor.black
        }
    }
    
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
           textView.text = textViewPlaceHolder
           textView.textColor = UIColor.lightGray
        }
    }
}

class CreateViewModel {
    
    private let manager = DiaryListManager.shared
    
    func add(_ item: DiaryItem) {
        manager.add(item)
    }
    
}
