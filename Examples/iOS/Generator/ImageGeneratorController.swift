//
//  ImageGeneratorController.swift
//  iOS Example
//
//  Created by EyreFree on 2023/7/8.
//  Copyright © 2023 EyreFree. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Photos
import EFQRCode
import MobileCoreServices

class ImageGeneratorController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    #if os(iOS)
    var imagePicker: UIImagePickerController?
    #endif

    var textView: UITextView!
    var tableView: UITableView!
    var createButton: UIButton!

    var titleCurrent: String = ""
    let lastContent = StorageUserDefaults<NSString>(key: "lastContent")

    // MARK: - Param
    var inputCorrectionLevel: EFCorrectionLevel = .h
    var image: EFStyleParamImage? = nil
    var imageMode: EFImageMode = .scaleAspectFill
    var imageAlpha: CGFloat = 1
    var dataStyle: EFStyleParamsDataStyle = .rectangle
    var dataDarkColor: UIColor = UIColor.black
    var dataDarkColorAlpha: CGFloat = 1
    var dataLightColor: UIColor = UIColor.white
    var dataLightColorAlpha: CGFloat = 1
    var dataThickness: CGFloat = 0.33
    var positionStyle: EFStyleParamsPositionStyle = .rectangle
    var positionThickness: CGFloat = 1
    var positionDarkColor: UIColor = UIColor.black
    var positionDarkAlpha: CGFloat = 1
    var positionLightColor: UIColor = UIColor.white
    var positionLightAlpha: CGFloat = 1
    var alignStyle: EFStyleImageParamAlignStyle = .none
    var alignSize: CGFloat = 1
    var alignDarkColor: UIColor = UIColor.black
    var alignDarkColorAlpha: CGFloat = 1
    var alignLightColor: UIColor = UIColor.white
    var alignLightColorAlpha: CGFloat = 1
    var timingStyle: EFStyleImageParamTimingStyle = .none
    var timingSize: CGFloat = 1
    var timingDarkColor: UIColor = UIColor.black
    var timingDarkColorAlpha: CGFloat = 1
    var timingLightColor: UIColor = UIColor.white
    var timingLightColorAlpha: CGFloat = 1
    var icon: EFStyleParamImage? = nil
    var iconScale: CGFloat = 0.22
    var iconAlpha: CGFloat = 1
    var iconBorderColor: UIColor = UIColor.white
    var iconBorderAlpha: CGFloat = 1
    // Backdrop
    var backdropCornerRadius: CGFloat = 0
    var backdropColor: UIColor = UIColor.white
    var backdropColorAlpha: CGFloat = 1
    var backdropImage: CGImage? = nil
    var backdropImageAlpha: CGFloat = 1
    var backdropImageMode: EFImageMode = .scaleAspectFill
    var backdropQuietzone: CGFloat? = nil
}

extension ImageGeneratorController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Create Image", comment: "Title on generator")
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.8117647059, blue: 0.7803921569, alpha: 1)

        setupViews()
        
        DispatchQueue.main.async {
            if let cgImage = UIImage(named: "Jobs")?.cgImage {
                self.image = EFStyleParamImage.static(image: cgImage)
                self.refresh()
            }
        }
    }

    func setupViews() {
        let buttonHeight: CGFloat = 46

        // MARK: Content
        textView = UITextView()
        textView.text = (lastContent.value as String?) ?? "https://github.com/EFPrefix/EFQRCode"
        textView.tintColor = #colorLiteral(red: 0.3803921569, green: 0.8117647059, blue: 0.7803921569, alpha: 1)
        textView.font = .systemFont(ofSize: 24)
        textView.textColor = .white
        textView.backgroundColor = UIColor.white.withAlphaComponent(0.32)
        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.delegate = self
        textView.returnKeyType = .done
        view.addSubview(textView)
        textView.snp.makeConstraints {
            (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(view).offset(-10)
            make.top.equalTo(CGFloat.statusBar() + CGFloat.navigationBar(self) + 15)
            make.height.equalTo(view).dividedBy(3.0)
        }

        // MARK: tableView
        tableView = UITableView()
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = true
        #if os(iOS)
        tableView.separatorColor = .white
        #endif
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            (make) in
            make.leading.equalTo(0)
            make.top.equalTo(textView.snp.bottom)
            make.width.equalTo(view)
        }

        createButton = UIButton(type: .system)
        createButton.setTitle(title, for: .normal)
        createButton.setTitleColor(#colorLiteral(red: 0.9647058824, green: 0.537254902, blue: 0.8705882353, alpha: 1), for: .normal)
        createButton.backgroundColor = UIColor.white.withAlphaComponent(0.32)
        createButton.layer.borderColor = UIColor.white.cgColor
        createButton.layer.borderWidth = 1
        createButton.layer.cornerRadius = 5
        createButton.layer.masksToBounds = true
        #if os(iOS)
        createButton.addTarget(self, action: #selector(createCode), for: .touchDown)
        #else
        createButton.addTarget(self, action: #selector(createCode), for: .primaryActionTriggered)
        #endif
        view.addSubview(createButton)
        createButton.snp.makeConstraints {
            (make) in
            make.leading.trailing.equalTo(textView)
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(-10)
        }
    }

    #if os(iOS)
    override func viewWillLayoutSubviews() {
        textView.snp.updateConstraints {
            (make) in
            make.top.equalTo(CGFloat.statusBar() + CGFloat.navigationBar(self) + 15)
            if #available(iOS 11.0, *) {
                make.leading.equalTo(max(view.safeAreaInsets.left, 10))
                make.trailing.equalTo(view).offset(-max(view.safeAreaInsets.right, 10))
            }
        }
        if #available(iOS 11.0, *) {
            createButton.snp.updateConstraints {
                (make) in
                make.bottom.equalTo(-max(10, view.safeAreaInsets.bottom))
            }
        }
        super.viewWillLayoutSubviews()
    }
    #endif

    func refresh() {
        tableView.reloadData()
    }

    @objc func createCode() {
        // Lock user activity
        createButton.isEnabled = false
        // Recover user activity
        defer { createButton.isEnabled = true }

        let content = textView.text ?? ""
        lastContent.value = content as NSString

        let paramIcon: EFStyleParamIcon? = {
            if let icon = self.icon {
                return EFStyleParamIcon(
                    image: icon,
                    mode: .scaleAspectFill,
                    alpha: iconAlpha,
                    borderColor: iconBorderColor.withAlphaComponent(iconBorderAlpha).cgColor,
                    percentage: iconScale
                )
            }
            return nil
        }()
        
        let paramWatermark: EFStyleImageParamsImage? = {
            if let image = self.image {
                return EFStyleImageParamsImage(image: image, mode: imageMode, alpha: imageAlpha, allowTransparent: true)
            }
            return nil
        }()
        
        let backdropImage: EFStyleParamBackdropImage? = {
            if let backdropImage = self.backdropImage {
                return EFStyleParamBackdropImage(image: backdropImage, alpha: backdropImageAlpha, mode: backdropImageMode)
            }
            return nil
        }()
        
        let backdropQuietzone: EFEdgeInsets? = {
            if let backdropQuietzone = self.backdropQuietzone {
                return EFEdgeInsets(top: backdropQuietzone, left: backdropQuietzone, bottom: backdropQuietzone, right: backdropQuietzone)
            }
            return nil
        }()
        
        do {
            let generator = try EFQRCode.Generator(
                content,
                encoding: .utf8,
                errorCorrectLevel: inputCorrectionLevel,
                style: EFQRCodeStyle.image(
                    params: EFStyleImageParams(
                        icon: paramIcon,
                        backdrop: EFStyleParamBackdrop(
                            cornerRadius: backdropCornerRadius,
                            color: backdropColor.withAlphaComponent(backdropColorAlpha).cgColor,
                            image: backdropImage,
                            quietzone: backdropQuietzone
                        ),
                        align: EFStyleImageParamsAlign(
                            style: alignStyle,
                            size: alignSize,
                            colorDark: alignDarkColor.withAlphaComponent(alignDarkColorAlpha).cgColor,
                            colorLight: alignLightColor.withAlphaComponent(alignLightColorAlpha).cgColor
                        ),
                        timing: EFStyleImageParamsTiming(
                            style: timingStyle,
                            size: timingSize,
                            colorDark: timingDarkColor.withAlphaComponent(timingDarkColorAlpha).cgColor,
                            colorLight: timingLightColor.withAlphaComponent(timingLightColorAlpha).cgColor
                        ),
                        position: EFStyleImageParamsPosition(
                            style: positionStyle,
                            size: positionThickness,
                            colorDark: positionDarkColor.withAlphaComponent(positionDarkAlpha).cgColor,
                            colorLight: positionLightColor.withAlphaComponent(positionLightAlpha).cgColor
                        ),
                        data: EFStyleImageParamsData(
                            style: dataStyle,
                            scale: dataThickness,
                            colorDark: dataDarkColor.withAlphaComponent(dataDarkColorAlpha).cgColor,
                            colorLight: dataLightColor.withAlphaComponent(dataLightColorAlpha).cgColor
                        ),
                        image: paramWatermark
                    )
                )
            )
            let image: EFImage = {
                let imageWidth: CGFloat = CGFloat((generator.qrcode.model.moduleCount + 1) * 12)
                if generator.isAnimated {
                    //let testData = try! generator.toMp4Data(width: imageWidth)
                    //saveVideoToAlbum(format: .mp4, videoData: testData)
                    
                    return EFImage.gif(try! generator.toGIFData(width: imageWidth))
                } else {
                    return EFImage.normal(try! generator.toImage(width: imageWidth))
                }
            }()
            
            let showVC = ShowController(image: image)
            showVC.svgString = (try? generator.toSVG()) ?? ""
            present(showVC, animated: true)
        } catch {
            let alert = UIAlertController(
                title: Localized.error,
                message: error.localizedDescription,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localized.ok, style: .cancel))
            present(alert, animated: true)
        }
    }
    
    func saveVideoToAlbum(format: EFVideoFormat, videoData: Data) {
        // 首先检查权限
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                // 处理未授权情况
                return
            }
            
            // 创建临时文件
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "." + format.fileExtension)
            
            do {
                // 将数据写入临时文件
                try videoData.write(to: tempURL)
                
                // 保存到相册
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
                }) { success, error in
                    // 清理临时文件
                    try? FileManager.default.removeItem(at: tempURL)
                    
                    if success {
                        print("Video saved successfully")
                    } else if let error = error {
                        print("Error saving video: \(error)")
                    }
                }
            } catch {
                print("Error writing video data: \(error)")
            }
        }
    }

    // UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 键盘提交
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func chooseInputCorrectionLevel() {
        chooseFromEnum(title: Localized.Title.inputCorrectionLevel, type: EFCorrectionLevel.self) { [weak self] result in
            guard let self = self else { return }
            
            self.inputCorrectionLevel = result
            self.refresh()
        }
    }

    func chooseDataDarkColor() {
        let alert = UIAlertController(
            title: Localized.Title.dataDarkColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(0)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.dataDarkColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseDataDarkColorAlpha() {
        chooseFromList(title: Localized.Title.dataDarkColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.dataDarkColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseDataLightColor() {
        let alert = UIAlertController(
            title: Localized.Title.dataLightColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(1)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.dataLightColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseDataLightColorAlpha() {
        chooseFromList(title: Localized.Title.dataLightColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.dataLightColorAlpha = result
            self.refresh()
        }
    }

    func chooseIcon() {
        let alert = UIAlertController(
            title: Localized.Title.icon,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: Localized.none, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.icon = nil
                self.refresh()
            }
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.chooseImage, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.chooseImageFromAlbum(title: Localized.Title.icon)
                self.refresh()
            }
        )
        #endif
        for (index, icon) in Localized.Parameters.iconNames.enumerated() {
            alert.addAction(
                UIAlertAction(title: icon, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    
                    if let cgImage = UIImage(named: ["EyreFree", "GitHub", "Pikachu", "Swift"][index])?.cgImage {
                        self.icon = EFStyleParamImage.static(image: cgImage)
                        self.refresh()
                    }
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseWatermark() {
        let alert = UIAlertController(
            title: Localized.Title.watermark,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: Localized.none, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.image = nil
                self.refresh()
            }
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.chooseImage, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.chooseImageFromAlbum(title: Localized.Title.watermark)
                self.refresh()
            }
        )
        #endif
        for (index, localizedName) in Localized.Parameters.watermarkNames.enumerated() {
            alert.addAction(
                UIAlertAction(title: localizedName, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    
                    if let cgImage = UIImage(named: ["Beethoven", "Jobs", "Miku", "Wille", "WWF"][index])?.cgImage {
                        self.image = EFStyleParamImage.static(image: cgImage)
                        self.refresh()
                    }
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseDataThickness() {
        chooseFromList(title: Localized.Title.dataThickness, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.dataThickness = result
            self.refresh()
        }
    }
    
    func choosePositionStyle() {
        chooseFromEnum(title: Localized.Title.positionStyle, type: EFStyleParamsPositionStyle.self) { [weak self] result in
            guard let self = self else { return }
            
            self.positionStyle = result
            self.refresh()
        }
    }
    
    func choosePositionThickness() {
        chooseFromList(title: Localized.Title.positionThickness, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.positionThickness = result
            self.refresh()
        }
    }
    
    func choosePositionDarkColor() {
        let alert = UIAlertController(
            title: Localized.Title.positionDarkColorAlpha,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(2)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.positionDarkColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func choosePositionDarkAlpha() {
        chooseFromList(title: Localized.Title.positionDarkColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.positionDarkAlpha = result
            self.refresh()
        }
    }
    
    func choosePositionLightColor() {
        let alert = UIAlertController(
            title: Localized.Title.positionLightColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(3)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.positionLightColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func choosePositionLightAlpha() {
        chooseFromList(title: Localized.Title.positionLightColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.positionLightAlpha = result
            self.refresh()
        }
    }
    
    func chooseWatermarkAlpha() {
        chooseFromList(title: Localized.Title.watermarkAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.imageAlpha = result
            self.refresh()
        }
    }
    
    func chooseImageMode() {
        chooseFromEnum(title: Localized.Title.imageMode, type: EFImageMode.self) { [weak self] result in
            guard let self = self else { return }
            
            self.imageMode = result
            self.refresh()
        }
    }
    
    func chooseDataStyle() {
        chooseFromEnum(title: Localized.Title.dataStyle, type: EFStyleParamsDataStyle.self) { [weak self] result in
            guard let self = self else { return }
            
            self.dataStyle = result
            self.refresh()
        }
    }
    
    func chooseAlignStyle() {
        chooseFromEnum(title: Localized.Title.alignStyle, type: EFStyleImageParamAlignStyle.self) { [weak self] result in
            guard let self = self else { return }
            
            self.alignStyle = result
            self.refresh()
        }
    }
    
    func chooseAlignSize() {
        chooseFromList(title: Localized.Title.alignSize, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.alignSize = result
            self.refresh()
        }
    }
    
    func chooseAlignDarkColor() {
        let alert = UIAlertController(
            title: Localized.Title.alignDarkColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(4)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.alignDarkColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }

    func chooseAlignDarkColorAlpha() {
        chooseFromList(title: Localized.Title.alignDarkColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.alignDarkColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseAlignLightColor() {
        let alert = UIAlertController(
            title: Localized.Title.alignLightColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(5)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.alignLightColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }

    func chooseAlignLightColorAlpha() {
        chooseFromList(title: Localized.Title.alignLightColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.alignLightColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseTimingStyle() {
        chooseFromEnum(title: Localized.Title.timingStyle, type: EFStyleImageParamTimingStyle.self) { [weak self] result in
            guard let self = self else { return }
            
            self.timingStyle = result
            self.refresh()
        }
    }
    
    func chooseTimingSize() {
        chooseFromList(title: Localized.Title.timingSize, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.timingSize = result
            self.refresh()
        }
    }
    
    func chooseTimingDarkColor() {
        let alert = UIAlertController(
            title: Localized.Title.timingDarkColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(6)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.timingDarkColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }

    func chooseTimingDarkColorAlpha() {
        chooseFromList(title: Localized.Title.timingDarkColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.timingDarkColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseTimingLightColor() {
        let alert = UIAlertController(
            title: Localized.Title.timingLightColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(7)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.timingLightColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }

    func chooseTimingLightColorAlpha() {
        chooseFromList(title: Localized.Title.timingLightColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.timingLightColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseIconScale() {
        chooseFromList(title: Localized.Title.iconScale, items: [0, 0.11, 0.22, 0.33]) { [weak self] result in
            guard let self = self else { return }
            
            self.iconScale = result
            self.refresh()
        }
    }
    
    func chooseIconAlpha() {
        chooseFromList(title: Localized.Title.iconAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.iconAlpha = result
            self.refresh()
        }
    }
    
    func chooseIconBorderColor() {
        let alert = UIAlertController(
            title: Localized.Title.iconBorderColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(8)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.iconBorderColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseIconBorderColorAlpha() {
        chooseFromList(title: Localized.Title.iconBorderAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.iconBorderAlpha = result
            self.refresh()
        }
    }
    
    // Backdrop
    func chooseBackdropCornerRadius() {
        chooseFromList(title: Localized.Title.backdropCornerRadius, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.backdropCornerRadius = result
            self.refresh()
        }
    }
    
    func chooseBackdropColor() {
        let alert = UIAlertController(
            title: Localized.Title.backdropColor,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.custom, style: .default) {
                [weak self] _ in
                self?.customColor(9)
            }
        )
        #endif
        for color in Localized.Parameters.colors {
            alert.addAction(
                UIAlertAction(title: color.name, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    self.backdropColor = color.color
                    self.refresh()
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseBackdropColorAlpha() {
        chooseFromList(title: Localized.Title.alignColorAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.backdropColorAlpha = result
            self.refresh()
        }
    }
    
    func chooseBackdropImage() {
        let alert = UIAlertController(
            title: Localized.Title.backdropImage,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(title: Localized.cancel, style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: Localized.none, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.backdropImage = nil
                self.refresh()
            }
        )
        #if os(iOS)
        alert.addAction(
            UIAlertAction(title: Localized.chooseImage, style: .default) {
                [weak self] _ in
                guard let self = self else { return }
                self.chooseImageFromAlbum(title: Localized.Title.backdropImage)
                self.refresh()
            }
        )
        #endif
        for (index, icon) in Localized.Parameters.watermarkNames.enumerated() {
            alert.addAction(
                UIAlertAction(title: icon, style: .default) {
                    [weak self] _ in
                    guard let self = self else { return }
                    
                    if let cgImage = UIImage(named: Localized.Parameters.watermarkNames[index])?.cgImage {
                        self.backdropImage = cgImage
                        self.refresh()
                    }
                }
            )
        }
        popActionSheet(alert: alert)
    }
    
    func chooseBackdropImageAlpha() {
        chooseFromList(title: Localized.Title.backdropImageAlpha, items: [0, 0.25, 0.5, 0.75, 1]) { [weak self] result in
            guard let self = self else { return }
            
            self.backdropImageAlpha = result
            self.refresh()
        }
    }
    
    func chooseBackdropImageMode() {
        chooseFromEnum(title: Localized.Title.backdropImageMode, type: EFImageMode.self) { [weak self] result in
            guard let self = self else { return }
            
            self.backdropImageMode = result
            self.refresh()
        }
    }
    
    func chooseBackdropQuietzone() {
        chooseFromList(title: Localized.Title.backdropQuietzone, items: ["nil", "0", "0.25", "0.5", "0.75", "1"]) { [weak self] result in
            guard let self = self else { return }
            
            if let double = Double(result) {
                self.backdropQuietzone = CGFloat(double)
            } else {
                self.backdropQuietzone = nil
            }
            self.refresh()
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    static let titles = [
        Localized.Title.inputCorrectionLevel,
        Localized.Title.watermark,
        Localized.Title.imageMode,
        Localized.Title.watermarkAlpha,
        Localized.Title.dataStyle,
        Localized.Title.dataDarkColor,
        Localized.Title.dataDarkColorAlpha,
        Localized.Title.dataLightColor,
        Localized.Title.dataLightColorAlpha,
        Localized.Title.dataThickness,
        Localized.Title.positionStyle,
        Localized.Title.positionThickness,
        Localized.Title.positionDarkColor,
        Localized.Title.positionDarkColorAlpha,
        Localized.Title.positionLightColor,
        Localized.Title.positionLightColorAlpha,
        Localized.Title.alignStyle,
        Localized.Title.alignSize,
        Localized.Title.alignDarkColor,
        Localized.Title.alignDarkColorAlpha,
        Localized.Title.alignLightColor,
        Localized.Title.alignLightColorAlpha,
        Localized.Title.timingStyle,
        Localized.Title.timingSize,
        Localized.Title.timingDarkColor,
        Localized.Title.timingDarkColorAlpha,
        Localized.Title.timingLightColor,
        Localized.Title.timingLightColorAlpha,
        Localized.Title.icon,
        Localized.Title.iconScale,
        Localized.Title.iconAlpha,
        Localized.Title.iconBorderColor,
        Localized.Title.iconBorderAlpha,
        Localized.Title.backdropCornerRadius,
        Localized.Title.backdropColor,
        Localized.Title.backdropColorAlpha,
        Localized.Title.backdropImage,
        Localized.Title.backdropImageAlpha,
        Localized.Title.backdropImageMode,
        Localized.Title.backdropQuietzone
    ]
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        [
            chooseInputCorrectionLevel,
            chooseWatermark,
            chooseImageMode,
            chooseWatermarkAlpha,
            chooseDataStyle,
            chooseDataDarkColor,
            chooseDataDarkColorAlpha,
            chooseDataLightColor,
            chooseDataLightColorAlpha,
            chooseDataThickness,
            choosePositionStyle,
            choosePositionThickness,
            choosePositionDarkColor,
            choosePositionDarkAlpha,
            choosePositionLightColor,
            choosePositionLightAlpha,
            chooseAlignStyle,
            chooseAlignSize,
            chooseAlignDarkColor,
            chooseAlignDarkColorAlpha,
            chooseAlignLightColor,
            chooseAlignLightColorAlpha,
            chooseTimingStyle,
            chooseTimingSize,
            chooseTimingDarkColor,
            chooseTimingDarkColorAlpha,
            chooseTimingLightColor,
            chooseTimingLightColorAlpha,
            chooseIcon,
            chooseIconScale,
            chooseIconAlpha,
            chooseIconBorderColor,
            chooseIconBorderColorAlpha,
            chooseBackdropCornerRadius,
            chooseBackdropColor,
            chooseBackdropColorAlpha,
            chooseBackdropImage,
            chooseBackdropImageAlpha,
            chooseBackdropImageMode,
            chooseBackdropQuietzone
        ][indexPath.row]()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Self.titles.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zeroHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zeroHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailArray = [
            "\(inputCorrectionLevel)",
            "", // watermark
            "\(imageMode)",
            "\(imageAlpha)",
            "\(dataStyle)",
            "", // dataDarkColor
            "\(dataDarkColorAlpha)",
            "", // dataLightColor
            "\(dataLightColorAlpha)",
            "\(dataThickness)",
            "\(positionStyle)",
            "\(positionThickness)",
            "", // positionDarkColor
            "\(positionDarkAlpha)",
            "", // positionLightColor
            "\(positionLightAlpha)",
            "\(alignStyle)",
            "\(alignSize)",
            "", // alignDarkColor
            "\(alignDarkColorAlpha)",
            "", // alignLightColor
            "\(alignLightColorAlpha)",
            "\(timingStyle)",
            "\(timingSize)",
            "", // timingDarkColor
            "\(timingDarkColorAlpha)",
            "", // timingLightColor
            "\(timingLightColorAlpha)",
            "", // icon
            "\(iconScale)",
            "\(iconAlpha)",
            "", // iconBorderColor
            "\(iconBorderAlpha)",
            "\(backdropCornerRadius)",
            "", // backdropColor
            "\(backdropColorAlpha)",
            "", // backdropImage
            "\(backdropImageAlpha)",
            "\(backdropImageMode)",
            "\(String(describing: backdropQuietzone))"
        ]

        let cell = UITableViewCell(style: detailArray[indexPath.row] == "" ? .default : .value1, reuseIdentifier: nil)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.textLabel?.text = Self.titles[indexPath.row]
        cell.detailTextLabel?.text = detailArray[indexPath.row]
        let backView = UIView()
        backView.backgroundColor = UIColor.white.withAlphaComponent(0.64)
        cell.selectedBackgroundView = backView

        if detailArray[indexPath.row] == "" {
            let rightImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            #if os(iOS)
            if #available(iOS 11.0, *) {
                rightImageView.accessibilityIgnoresInvertColors = true
            }
            #endif
            rightImageView.contentMode = .scaleAspectFit
            rightImageView.layer.borderColor = UIColor.white.cgColor
            rightImageView.layer.borderWidth = 0.5
            cell.contentView.addSubview(rightImageView)
            cell.accessoryView = rightImageView

            switch indexPath.row {
            case 1:
                switch image {
                case .static(let image):
                    rightImageView.image = UIImage(cgImage: image)
                    break
                case .animated(let images, _):
                    rightImageView.image = UIImage(cgImage: images[0])
                    break
                case .none:
                    rightImageView.image = nil
                    break
                }
            case 5:
                rightImageView.backgroundColor = dataDarkColor.withAlphaComponent(dataDarkColorAlpha)
            case 7:
                rightImageView.backgroundColor = dataLightColor.withAlphaComponent(dataLightColorAlpha)
            case 12:
                rightImageView.backgroundColor = positionDarkColor.withAlphaComponent(positionDarkAlpha)
            case 14:
                rightImageView.backgroundColor = positionLightColor.withAlphaComponent(positionLightAlpha)
            case 18:
                rightImageView.backgroundColor = alignDarkColor.withAlphaComponent(alignDarkColorAlpha)
            case 20:
                rightImageView.backgroundColor = alignLightColor.withAlphaComponent(alignLightColorAlpha)
            case 24:
                rightImageView.backgroundColor = timingDarkColor.withAlphaComponent(timingDarkColorAlpha)
            case 26:
                rightImageView.backgroundColor = timingLightColor.withAlphaComponent(timingLightColorAlpha)
            case 28:
                switch icon {
                case .static(let image):
                    rightImageView.image = UIImage(cgImage: image)
                    break
                case .animated(let images, _):
                    rightImageView.image = UIImage(cgImage: images[0])
                    break
                case .none:
                    rightImageView.image = nil
                    break
                }
            case 31:
                rightImageView.backgroundColor = iconBorderColor.withAlphaComponent(iconBorderAlpha)
            case 34:
                rightImageView.backgroundColor = backdropColor.withAlphaComponent(backdropColorAlpha)
            case 36:
                rightImageView.image = backdropImage.flatMap { UIImage(cgImage: $0) }
            default:
                break
            }
        }
        return cell
    }
}

#if os(iOS)
// MARK: - EFColorPicker
extension ImageGeneratorController: UIColorPickerViewControllerDelegate {
    
    struct EFColorPicker {
        static var index: Int = 0
    }

    func customColor(_ index: Int) {
        EFColorPicker.index = index

        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.selectedColor = [
            dataDarkColor,
            dataLightColor,
            positionDarkColor,
            positionLightColor,
            alignDarkColor,
            alignLightColor,
            timingDarkColor,
            timingLightColor,
            iconBorderColor,
            backdropColor
        ][index]
        colorPicker.supportsAlpha = false
        present(colorPicker, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        dismiss(animated: true)
        refresh()
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        switch EFColorPicker.index {
        case 0:
            dataDarkColor = color
            break
        case 1:
            dataLightColor = color
            break
        case 2:
            positionDarkColor = color
            break
        case 3:
            positionLightColor = color
            break
        case 4:
            alignDarkColor = color
            break
        case 5:
            alignLightColor = color
            break
        case 6:
            timingDarkColor = color
            break
        case 7:
            timingLightColor = color
            break
        case 8:
            iconBorderColor = color
            break
        case 9:
            backdropColor = color
            break
        default:
            break
        }
        refresh()
    }
}
#endif

#if os(iOS)
extension ImageGeneratorController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var finalImage: UIImage?
        if let tryImage = info[.editedImage] as? UIImage {
            finalImage = tryImage
        } else if let tryImage = info[.originalImage] as? UIImage {
            finalImage = tryImage
        } else {
            print(Localized.errored)
        }

        let imageContent: EFStyleParamImage? = {
            var content: EFStyleParamImage? = nil
            if let finalImage = finalImage?.cgImage {
                content = .static(image: finalImage)
            } else {
                content = nil
            }
            var images = [Ref<EFImage?>]()
            if let imageUrl = info[.referenceURL] as? URL,
                let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil).lastObject {
                images = selectedAlbumPhotosIncludingGifWithPHAssets(assets: [asset])
            }
            if let tryGIF = images.first(where: { $0.value?.isGIF == true }) {
                if case .gif(let data) = tryGIF.value {
                    if let animatedImage = AnimatedImage(data: data, format: .gif) {
                        let frames = animatedImage.frames.compactMap { return $0 }
                        let frameDelays = animatedImage.frameDelays.map({ CGFloat($0) })
                        content = .animated(images: frames, imageDelays: frameDelays)
                    }
                }
            }
            return content
        }()
        
        switch titleCurrent {
        case Localized.Title.watermark:
            image = imageContent
        case Localized.Title.icon:
            icon = imageContent
        case Localized.Title.backdropImage:
            backdropImage = imageContent?.firstImage
        default:
            break
        }
        refresh()

        picker.dismiss(animated: true)
    }

    /// 选择相册图片（包括 GIF 图片）
    /// http://www.jianshu.com/p/ad391f4d0bcb
    func selectedAlbumPhotosIncludingGifWithPHAssets(assets: [PHAsset]) -> [Ref<EFImage?>] {
        var imageArray = [Ref<EFImage?>]()

        let targetSize = CGSize(width: 1024, height: 1024)

        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isSynchronous = true

        let imageManager = PHCachingImageManager()
        for asset in assets {
            imageManager.requestImageData(for: asset, options: options) {
                [weak self] (imageData, dataUTI, orientation, info) in
                guard self != nil else { return }
                print("dataUTI: \(dataUTI ?? Localized.none)")

                let imageElement: Ref<EFImage?> = nil

                if kUTTypeGIF as String == dataUTI {
                    // MARK: GIF
                    if let imageData = imageData {
                        imageElement.value = .gif(imageData)
                    }
                } else {
                    // MARK: 其他格式的图片，直接请求压缩后的图片
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) {
                        [weak self] (result, info) in
                        guard self != nil,
                            let result = result,
                            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool,
                            !isDegraded
                            else { return }
                        // 得到一张 UIImage，展示到界面上
                        imageElement.value = .normal(result)
                    }
                }

                imageArray.append(imageElement)
            }
        }
        return imageArray
    }

    func chooseImageFromAlbum(title: String) {
        titleCurrent = title

        if let tryPicker = imagePicker {
            present(tryPicker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = false
            imagePicker = picker

            present(picker, animated: true)
        }
    }
}
#endif
