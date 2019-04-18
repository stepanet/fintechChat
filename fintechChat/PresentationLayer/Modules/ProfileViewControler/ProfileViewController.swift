//
//  ProfileViewController.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 14/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var takePicturesForProfile: UIButton!
    @IBOutlet var profileNameTxt: UITextField!
    @IBOutlet weak var aboutProfileTextView: UITextView!

    @IBOutlet weak var gcdBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var saveDataOnMemory = SaveData()
    var imageFromLoad: UIImageView?
    var linkToImageFromLoad: URL?
    //let operationQueue = ReadWriteData.OperationDataManager()
    let gcdQueue = ReadWriteData.GCDDataManager()
    
    let coreDate = CoreDataStack.shared

    enum ImageSource {
        case photoLibrary
        case camera
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //невозможно. еще не определены view, subview, переменные
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        aboutProfileTextView.delegate = self
        profileNameTxt.delegate = self
        keyboardSetup()
        loadProfileData()
    }

    override func viewWillAppear(_ animated: Bool) {
        //настроим интерфейс
        setupUI()
        if self.linkToImageFromLoad == nil {
        btnEditUnHidden()
        fieldProfileDisable()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //уже известны точные размеры вью и размеры кнопки
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //если изменили текст то поставим флаг - сохранить
    func textViewDidChange(_ textView: UITextView) {
        saveDataOnMemory.saveAbout = true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //максимум 60 символов
        if (profileNameTxt.text?.count)! < 61 {
            self.saveDataOnMemory.saveProfileName = true
            return true
        } else {
            profileNameTxt.text?.removeLast()
            return true
        }
    }

    @IBAction func tekePIctureBtnAction(_ sender: UIButton) {
        print("Выбери изображение профиля")
        takePhotoProfile(cameraOff: false)
    }

    //подгрузим данные в профиль
    private func loadProfileData() {

        coreDate.mainContext.perform {
            
            if self.linkToImageFromLoad != nil {
                DispatchQueue.main.async {
                    self.profileImageView.downloadedFrom(url: self.linkToImageFromLoad!, contentMode: .scaleAspectFill)
                    self.linkToImageFromLoad = nil
                }
                self.editBtn.isHidden = true
                self.gcdBtn.isHidden = false
                
                //return
            }
            //считываем данные  из coreDate
            let model = self.coreDate.managedObjectModel
            let user = AppUser.fetchRequest(model: model, templateName: "AppUser")
            let result =  try? self.coreDate.mainContext.fetch(user!)
            if result!.isEmpty {
                print("c o r e d a t a i s e m p t y ")
                return
            } else {
                let image = UIImage(data: (result?.first?.image)!)
                self.profileNameTxt.text =  result?.first?.name
                self.aboutProfileTextView.text = result?.first?.about
//            if self.linkToImageFromLoad != nil {
//                DispatchQueue.main.async {
//                    self.profileImageView.downloadedFrom(url: self.linkToImageFromLoad!, contentMode: .scaleAspectFill)
//                    self.linkToImageFromLoad = nil
//                }
//                self.editBtn.isHidden = true
//                self.gcdBtn.isHidden = false
//
//                return
//            }
            self.profileImageView.image = image

            }
        }

    }

    //выбор фотографии в профайл
    func handleSelectProfileImageView(_ source: ImageSource) {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true

        switch source {
            case .camera:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                takePhotoProfile(cameraOff: true)
                return
            }
             picker.sourceType = .camera
            case .photoLibrary:
                picker.sourceType = .photoLibrary
        }

        present(picker, animated: true, completion: {
            self.fieldProfileEnable()
        })

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        var selectImageFromPicker: UIImage?

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectImageFromPicker = originalImage
        }
        if let selectedImage = selectImageFromPicker {
            profileImageView.image = selectedImage
            self.saveDataOnMemory.savePhoto = true

        }
        dismiss(animated: true, completion: {
            self.btnSaveEnable()
            self.fieldProfileEnable()
            self.btnEditHidden()
            self.setupUI()
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    private func takePhotoProfile(cameraOff: Bool) {

        var titleForCamera = "Фото"

        if cameraOff {
            titleForCamera = "Камера не доступна"
        }

        let alertController = UIAlertController(title: "", message: "Выберите фотографию для профиля", preferredStyle: .actionSheet)
        let actionPhoto = UIAlertAction(title: titleForCamera, style: .default) { (_) in
            self.handleSelectProfileImageView(.camera)
        }
        let actionLibrary = UIAlertAction(title: "Библиотека", style: .default) { (_) in
            self.handleSelectProfileImageView(.photoLibrary)
        }
        let actionLoad = UIAlertAction(title: "Скачать", style: .default) { (_) in
            self.performSegue(withIdentifier: "downloadImage", sender: self)
        }
        let deletePhotoProfile = UIAlertAction(title: "Удалить фото", style: .destructive) { (_) in
            let selectedImage = UIImage(named: "placeholder-user")
            self.profileImageView.image = selectedImage
            self.saveDataOnMemory.savePhoto = false
            self.gcdQueue.queueGlobal.async {
                self.gcdQueue.removeImage(nameOfFile: "userprofile.jpg")
            }
            self.btnSaveEnable()

        }
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
        }
        alertController.addAction(actionPhoto)
        alertController.addAction(actionLibrary)
        alertController.addAction(actionLoad)
        alertController.addAction(actionCancel)

        if self.profileImageView.image != UIImage(named: "placeholder-user") {
            alertController.addAction(deletePhotoProfile)
        }
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func closeProfileView(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }

    //Следим если юзер начал набирать текст или делать изменения
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.btnSaveEnable()
    }

    //открываем возможность редактировать профиль
    @IBAction func editData(_ sender: UIButton) {
        self.fieldProfileEnable()
        self.btnEditHidden()
        self.btnSaveDisable()
    }

    //делаем поля доступными для редактирования
    fileprivate func fieldProfileEnable() {
        self.profileNameTxt.isEnabled = true
        self.aboutProfileTextView.isEditable = true
        self.takePicturesForProfile.isEnabled = true
    }

    //делаем поля не доступными для редактирования
    fileprivate func fieldProfileDisable() {
        gcdQueue.queueMain.async {
            self.profileNameTxt.isEnabled = false
            self.aboutProfileTextView.isEditable = false
            self.takePicturesForProfile.isEnabled = false
        }
    }

    //если начато редактирование - активировать кнопки записи
    @IBAction func editActionStart(_ sender: Any) {
        self.btnSaveEnable()
    }

    //сохраняем данные
    @IBAction func safeData(_ sender: UIButton) {

        self.activityIndicator.startAnimating()
        self.btnSaveDisable()
        let imageData: Data = (self.profileImageView.image!.pngData())!
        let text = profileNameTxt.text!
        let textAbout = aboutProfileTextView.text!

        //work with coreData

        //очистим все
        coreDate.masterContext.perform {
            _ = AppUser.cleanDeleteAppUser(in: self.coreDate.masterContext)
            //записываем данные
            _ = AppUser.insertAppUser(in: self.coreDate.masterContext, name: text, timestamp: Date(), about: textAbout, image: imageData)
            try? self.coreDate.masterContext.save()
        }
        self.saveDataStart()
    }

    //safe data
    fileprivate func saveDataStart() {
        self.showAlert(textMessage: self.saveDataOnMemory.textAlertFunc())
        self.fieldProfileDisable()
        self.btnAfterSave()
        self.loadProfileData()
    }

    //button and activity state
    fileprivate func btnAfterSave() {
        self.btnSaveEnable()
        self.btnEditUnHidden()
    }

    //safe button disable
    fileprivate func btnSaveDisable() {
            self.gcdBtn.isEnabled = false
            self.gcdBtn.changeColor(self.gcdBtn, state: false)
    }

    //safe button enable
    fileprivate func btnSaveEnable() {
        gcdQueue.queueMain.async {
            self.gcdBtn.pulsate()
            self.gcdBtn.changeColor(self.gcdBtn, state: true)
            self.gcdBtn.isEnabled = true
        }
    }

    //
    fileprivate func btnEditHidden() {
        editBtn.isHidden = true
        gcdBtn.isHidden = false
    }

    //
    fileprivate func btnEditUnHidden() {
        gcdQueue.queueMain.async {
            self.editBtn.isHidden = false
            self.gcdBtn.isHidden = true
        }
    }

    //алерт успешно / неуспешно
    func showAlert(textMessage: String) {
        let alertController = UIAlertController(title: nil, message: textMessage, preferredStyle: .alert)
        let actionSave = UIAlertAction(title: "ОК", style: .default) { (_) in
            self.activityIndicator.stopAnimating()
        }
        alertController.addAction(actionSave)
        self.present(alertController, animated: true, completion: nil)
    }

    func keyboardSetup() {
        // Keyboard notifications:
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillShowNotification, object: nil, queue: nil) { (_) in
            self.view.frame.origin.y = -270
        }
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillHideNotification, object: nil, queue: nil) { (_) in
            self.view.frame.origin.y = 0.0
        }
    }
}
