//
//  ScriptsDetailController.swift
//  Scripts Distributor
//
//  Created by Wen Chen on 8/29/24.
//

import UIKit

class ScriptsDetailController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    @IBOutlet weak var scriptImageView: UIImageView!
    @IBOutlet weak var scriptNameLabel: UILabel!
    @IBOutlet weak var scriptKindLabel: UILabel!
    @IBOutlet weak var scriptOtherLabel: UILabel!
    @IBOutlet weak var scriptIntroLabel: UILabel!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    var isImageViewFullscreen = false
    var originalFrame: CGRect?
    
    var scriptImage: UIImage?
    var scriptName: String?
    var scriptKind: String?
    var scriptOther: String?
    var scriptIntro: String?
    var scriptMember: [String]?
    
    var bgImage: UIImage?
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scriptImageView.image = scriptImage
        scriptNameLabel.text = scriptName
        scriptKindLabel.text = scriptKind
        scriptOtherLabel.text = scriptOther
        scriptIntroLabel.text = scriptIntro
//        bgImageView.image = scriptImage
        
        if let dominantColor = scriptImage!.getDominantColor() {
            print("Dominant color: \(dominantColor)")
            bgImageView.backgroundColor = dominantColor
        }
        
        // 设置 Collection View 的数据源和委托
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        // 为 UIImageView 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped1))
        scriptImageView.isUserInteractionEnabled = true  // 确保 UIImageView 是可交互的
        scriptImageView.addGestureRecognizer(tapGesture)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scriptMember!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScriptMemberCell", for: indexPath) as! ScriptsMemberCellController
        let memberName = scriptMember![indexPath.item]
        cell.imageView.image = UIImage(named: memberName)
        
        cell.imageView.tag = indexPath.item
        
        // 添加点击手势识别器到每个cell的UIImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped2))
        cell.imageView.isUserInteractionEnabled = true
        cell.imageView.addGestureRecognizer(tapGesture)

        return cell
    }
    
    @objc func imageTapped1() {
        selectedImage = scriptImageView.image
        performSegue(withIdentifier: "showBigPic", sender: self)
    }
    @objc func imageTapped2(_ sender: UITapGestureRecognizer) {
        // 获取点击的 UIImageView
        if let imageView = sender.view as? UIImageView {
            let index = imageView.tag  // 获取 tag，也就是 indexPath.item

            // 获取对应的图片
            if let selectedImageName = scriptMember?[index] {
                selectedImage = UIImage(named: selectedImageName)  // 保存选中的图片
                performSegue(withIdentifier: "showBigPic", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBigPic" {
            if let destinationVC = segue.destination as? BigPicController {
                destinationVC.bigView = selectedImage
            }
        }
        if segue.identifier == "toCreateRoom" {
            if let destinationVC = segue.destination as? CreateRoomViewController {
                destinationVC.scriptMember = scriptMember
                destinationVC.scriptName = scriptName
            }
        }
        if segue.identifier == "toJoinRoom" {
            if let destinationVC = segue.destination as? JoinRoomViewController {
                destinationVC.scriptMember = scriptMember
                destinationVC.scriptName = scriptName
            }
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

extension ScriptsDetailController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            // 设置行间距
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            // 设置列间距
        return 3
    }

}

extension UIImage {
    func getDominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
