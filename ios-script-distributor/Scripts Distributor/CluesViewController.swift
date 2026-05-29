import UIKit

class CluesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var playerRole: PlayerRole?
    var clueStages: [ClueStage] = []
    var script: Script!
    
    var clueImageURLs: [URL] = []

    // 用于保存选中的图片
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置 tableView 的数据源和代理
        tableView.dataSource = self
        tableView.delegate = self

        // 设置 collectionView 的数据源和代理
        collectionView.dataSource = self
        collectionView.delegate = self  // 确保设置了 delegate

        // 默认选中第一个阶段，加载线索
        if let firstStage = clueStages.first {
            loadClueImages(for: firstStage)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clueStages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ClueCell") ?? UITableViewCell(style: .default, reuseIdentifier: "ClueCell")
        let stage = clueStages[indexPath.row]
        cell.textLabel?.text = stage.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
        cell.textLabel?.textAlignment = .center
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stage = clueStages[indexPath.row]
        // 加载并显示对应的线索图片
        loadClueImages(for: stage)
    }

    func loadClueImages(for stage: ClueStage) {
        guard let role = playerRole else {
            print("玩家角色未确定")
            return
        }

        clueImageURLs.removeAll()

        // 加载公开线索
        if let publicImageURLStrings = script.publicClueImageURLsDict[stage.number] {
            for imageURLString in publicImageURLStrings {
                if let encodedURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let imageURL = URL(string: encodedURLString) {
                    clueImageURLs.append(imageURL)
                } else {
                    print("无法创建 URL：\(imageURLString)")
                }
            }
        }

        // 加载私有线索
        if let privateCluesForRole = script.privateClueImageURLsDict[role.name],
           let privateImageURLStrings = privateCluesForRole[stage.number] {
            for imageURLString in privateImageURLStrings {
                if let encodedURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let imageURL = URL(string: encodedURLString) {
                    clueImageURLs.append(imageURL)
                } else {
                    print("无法创建 URL：\(imageURLString)")
                }
            }
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBigPic" {
            if let destinationVC = segue.destination as? BigPicController {
                destinationVC.bigView = selectedImage
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CluesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clueImageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClueImageCell", for: indexPath) as! ClueImageCell
        let imageURL = clueImageURLs[indexPath.item]
        cell.configure(with: imageURL)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CluesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 获取选中的 Cell
        if let cell = collectionView.cellForItem(at: indexPath) as? ClueImageCell {
            // 获取 Cell 中的图片
            if let image = cell.imageView.image {
                // 保存选中的图片
                selectedImage = image
                // 执行 Segue 跳转到 BigPicController
                performSegue(withIdentifier: "showBigPic", sender: self)
            } else {
                print("图片尚未加载完成")
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CluesViewController: UICollectionViewDelegateFlowLayout {
    // 设置 Cell 的大小和间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 根据需要调整 Cell 的大小
        let itemsPerRow: CGFloat = 2
        let padding: CGFloat = 10
        let totalPadding = padding * (itemsPerRow - 1)
        let individualWidth = (collectionView.bounds.width - totalPadding) / itemsPerRow
        return CGSize(width: individualWidth, height: individualWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
