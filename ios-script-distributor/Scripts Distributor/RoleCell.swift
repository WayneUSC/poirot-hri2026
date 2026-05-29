import UIKit

class RoleCell: UICollectionViewCell {
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    // 添加按钮点击事件的闭包
    var buttonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // 初始化按钮的图标
        statusButton.setImage(UIImage(systemName: "circle"), for: .normal)
        statusButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        statusButton.tintColor = .systemBlue
        // 启用按钮的用户交互
        statusButton.isUserInteractionEnabled = true
        // 设置按钮的目标动作
        statusButton.addTarget(self, action: #selector(statusButtonTapped(_:)), for: .touchUpInside)

    }

    // 添加按钮的 IBAction
    @IBAction func statusButtonTapped(_ sender: UIButton) {
        // 调用闭包，将事件传递给视图控制器
        buttonAction?()
    }
    
}
