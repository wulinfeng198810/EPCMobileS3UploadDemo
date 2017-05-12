//
//  ViewController.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 02/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AWSS3

private let EPCUploadListCellID = "EPCUploadListCell"

class ViewController: UIViewController {

    lazy var tableView = UITableView()
    var dataArray = Array<EPCPhotoDBModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Picture",
                            style: .plain,
                            target: self,
                            action: #selector(popImagePicker))
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "UploadList",
                            style: .plain,
                            target: self,
                            action: #selector(pushToUploadList))
        
        setUI()
        
        loadHistoryUploadPhotos()
    }
    
    private func loadHistoryUploadPhotos() {
        guard let array = EPCSqliteMangager.shareInstance.findAllPhotoDBModel() else {
            return
        }
        
        for uploadPhoto in array {
        
            if uploadPhoto.transferState == .EPCPhotoUploadState_failed {
                EPCAwsS3TaskManager.manager.upload(photo: uploadPhoto, isNewTask:false)
            }
        }
        
        dataArray += array
        tableView.reloadData()
    }
    
    @objc private func popImagePicker() {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker(camera: true)
        }
        
        let albumAction = UIAlertAction(title: "Choose from Album", style: .default) { (_) in
            self.imagePicker(camera: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(cameraAction)
        sheet.addAction(albumAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true, completion: nil)
    }
    
    @objc private func pushToUploadList() {
        self.navigationController?.pushViewController(EPCUploadListController(), animated: true)
    }
    
    private func imagePicker(camera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType =  camera ? .camera : .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setUI() {
        view.backgroundColor = UIColor.white
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        
        view.addSubview(tableView)
        
        tableView.register(UINib(nibName: "EPCUploadListCell", bundle: nil),
                           forCellReuseIdentifier: EPCUploadListCellID)
    }
}

// MARK: - ImagePicker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image: UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            image = editedImg
        } else {
            if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                image = originalImg
            }
        }
        
        saveImageThenStartTask(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func saveImageThenStartTask(image: UIImage?) {
        
        guard let img = image,
            let data = UIImagePNGRepresentation(img) as NSData? else {
                return
        }
        
        let photoid = String.uuidString()
        let filePath = EPCDirectory.shareInstance.epcPhotoDirectory() + "/" + photoid + ".png"
        let fileURL = URL(fileURLWithPath: filePath)
        
        // save image, then create upload task
        let ret = data.write(to: fileURL, atomically: true)
        debugPrint("\n save image: \(ret ? "success" : "failed")")
        
        let photoDBModel = EPCPhotoDBModel()
        photoDBModel.photoid = photoid
        photoDBModel.transferState = .EPCPhotoUploadState_running
        
        dataArray.append(photoDBModel)
        tableView.reloadData()
        
        EPCAwsS3TaskManager.manager.upload(photo: photoDBModel, isNewTask: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EPCUploadListCellID) as! EPCUploadListCell
        cell.delegate = self
        cell.model = dataArray[indexPath.row]
        
        return cell
    }
    
}

// MARK: - EPCPhotoDBModelProtocol
extension ViewController: EPCPhotoDBModelProtocol {
    
    func EPCPhotoDBModelChangeState(photoModel: EPCPhotoDBModel) {
        EPCAwsS3TaskManager.manager.changeUpload(photoModel: photoModel)
    }
}
