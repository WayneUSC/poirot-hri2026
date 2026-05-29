import UIKit

class ClueImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage: UIImage?

    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置 imageView 的图片，避免重用时显示错误的图片
        imageView.image = UIImage(named: "placeholder")
    }

    func configure(with url: URL) {
        imageView.image = UIImage(named: "placeholder")

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("图片下载失败：\(error.localizedDescription)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("无法获取图片数据或创建 UIImage")
                return
            }

            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        task.resume()
    }
}
