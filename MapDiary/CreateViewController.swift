//
//  CreateViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/12.
//

import UIKit
import Photos
import RxCocoa
import RxSwift
import os

class CreateViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var completeButton: UIBarButtonItem!
    
    var imageMetadata = ImageMetadata(imageDate: nil, location: GPS(latitude: -190, longitude: -190))
    var isImagePicked = BehaviorSubject<Bool>(value: false)
   
    let textViewPlaceHolder = "내용을 입력해주세요"
    let viewModel = DiaryListViewModel()
    let imagePicker = UIImagePickerController()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.initImagePicker()
            self.placeholderSetting()
            self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showPhotoLibrary)))
        }
        
        checkValidation()
        checkPhotoLibraryAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(red: 30.0/255.0, green: 50.0/255.0, blue: 62.0/255.0, alpha: 1.0)
        
        self.title = "추억 만들기"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(red: 30.0/255.0, green: 50.0/255.0, blue: 62.0/255.0, alpha: 1.0)]
    }
    
    private func initImagePicker() {
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = false // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
    }
    
    private func checkPhotoLibraryAuth() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                if status != .authorized {
                    os_log("PhotoLibrary: Authorization not granted.", type: .info)
                }
            }
        }
    }
    
    private func checkValidation() {
        Observable.combineLatest(textView.rx.text.map(checkContentsValidation),
                                 titleTextField.rx.text.orEmpty.map({t in t.isEmpty == false}),
                                 isImagePicked, resultSelector: {r1, r2, r3 in r1 && r2 && r3})
            .subscribe(onNext: { b in
                self.completeButton.isEnabled = b})
            .disposed(by: disposeBag)
    }
    
    private func checkContentsValidation(_ contents: String?) -> Bool {
        guard let text = contents else { return false }
        return text != textViewPlaceHolder && !text.isEmpty
    }
    
    @objc private func showPhotoLibrary() {
        self.present(self.imagePicker, animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        
        guard let image = imageView.image?.downSample(scale: 0.2) else {return}
        guard let title = titleTextField.text else {return}
        guard let contents = textView.text else {return}
        
        let item = DiaryListManager.shared.createItem(image: image, title: title, contents: contents, metadata: imageMetadata)
        viewModel.add(item: item)
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreateViewController: UIImagePickerControllerDelegate, URLSessionDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage: UIImage? = nil // update 할 이미지
        
        if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage.downSample(scale: 0.2) // 원본 이미지가 있을 경우
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
            
            self.imageView.image = newImage // 받아온 이미지를 update
            self.isImagePicked.onNext(true)
            
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
