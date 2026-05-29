import UIKit
import FirebaseDatabase

class RoleSelectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var roles: [String]!
    
    var roomID: String = ""
    var ref: DatabaseReference!
    var playerID: String = ""
    var scriptName: String!
    var script: Script!
    
    var selectedRoles: [String] = []
    var currentPlayerSelectedRole: String?  // 当前玩家已选择的角色

    @IBOutlet weak var rolesCollectionView: UICollectionView!
    
    @IBOutlet weak var readyButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        playerID = UUID().uuidString

        rolesCollectionView.delegate = self
        rolesCollectionView.dataSource = self

        // 禁用单元格的点击事件，因为我们使用按钮来选择角色
        rolesCollectionView.allowsSelection = false

        // 初始化"准备"按钮
        readyButton.isEnabled = false
        readyButton.alpha = 0.5

        // 加载剧本数据
        loadScriptData()
        
        observeSelectedRoles()
        observeReadyStatus()
        
        addPlayerToRoom()
        
        ref.child("rooms/\(roomID)/readyStatus/\(playerID)").setValue(false)
//        print(scriptName)
    }

    func loadScriptData() {
        // 从 JSON 文件加载剧本数据
        if let script = loadScript(from: scriptName) {
            self.script = script
        } else {
            print("Couldn't Load Scripts Data")
            // 处理错误，例如显示提示信息
        }
    }

    func loadScript(from filename: String) -> Script? {
        // 实现从 JSON 文件加载剧本数据的函数
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Couldn't Find the File \(filename).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let script = try decoder.decode(Script.self, from: data)
            return script
        } catch {
            print("Mistakes When Decoding JSON ：\(error)")
            return nil
        }
    }

    func addPlayerToRoom() {
        ref.child("rooms/\(roomID)/players").observeSingleEvent(of: .value) { snapshot in
            var players = snapshot.value as? [String] ?? []
            if !players.contains(self.playerID) {
                players.append(self.playerID)
                self.ref.child("rooms/\(self.roomID)/players").setValue(players)
            }
        }
    }

    func observeSelectedRoles() {
        // 监听players数组变化，这样我们可以知道每个玩家的正确索引
        ref.child("rooms/\(roomID)/players").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            let players = snapshot.value as? [String] ?? []
            
            // 监听selectedRoles变化
            self.ref.child("rooms/\(self.roomID)/selectedRoles").observe(.value) { snapshot in
                // 解析selectedRoles数据
                var selectedRolesArray: [String] = []
                
                if let selectedRolesValue = snapshot.value {
                    if let array = selectedRolesValue as? [String] {
                        selectedRolesArray = array
                    } else if let dict = selectedRolesValue as? [String: String] {
                        // 转换字典为数组
                        selectedRolesArray = Array(repeating: "", count: max(players.count, dict.count))
                        for (key, value) in dict {
                            if let index = Int(key), index < selectedRolesArray.count {
                                selectedRolesArray[index] = value
                            }
                        }
                    }
                }
                
                // 保存非空角色
                self.selectedRoles = selectedRolesArray.filter { !$0.isEmpty }
                
                // 获取当前玩家选择的角色
                self.ref.child("rooms/\(self.roomID)/playerRoles/\(self.playerID)").observeSingleEvent(of: .value) { snapshot in
                    self.currentPlayerSelectedRole = snapshot.value as? String
                    
                    DispatchQueue.main.async {
                        self.rolesCollectionView.reloadData()
                        
                        // 更新"准备"按钮状态
                        if self.currentPlayerSelectedRole != nil {
                            self.readyButton.isEnabled = true
                            self.readyButton.alpha = 1.0
                        } else {
                            self.readyButton.isEnabled = false
                            self.readyButton.alpha = 0.5
                        }
                    }
                }
            }
        }
    }

    func observeReadyStatus() {
        ref.child("rooms/\(roomID)/readyStatus").observe(.value) { snapshot in
            let readyStatus = snapshot.value as? [String: Bool] ?? [:]
            // 获取当前房间中的玩家列表
            self.ref.child("rooms/\(self.roomID)/players").observeSingleEvent(of: .value) { playerSnapshot in
                let players = playerSnapshot.value as? [String] ?? []
                // 检查是否所有玩家都已准备
                let allReady = players.allSatisfy { playerID in
                    return readyStatus[playerID] == true
                }
                if allReady && !players.isEmpty {
                    // 所有玩家都已准备，跳转到游戏界面
                    self.navigateToGameScreen()
                }
            }
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Hint", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func readyButtonTapped(_ sender: UIButton) {
        // 将当前玩家的准备状态设置为 true
        ref.child("rooms/\(roomID)/readyStatus/\(playerID)").setValue(true)

        // 禁用"准备"按钮，防止重复点击
        readyButton.isEnabled = false
        readyButton.alpha = 0.5
    }

    func navigateToGameScreen() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toGameScreen", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGameScreen" {
            if let destinationVC = segue.destination as? GameViewController {
                destinationVC.roomID = roomID
                destinationVC.playerID = playerID
                destinationVC.script = script
            }
        }
    }

    // MARK: - Role Selection Logic
    
    func selectRole(roleName: String) {
        // 首先获取players数组，确定当前玩家的索引
        ref.child("rooms/\(roomID)/players").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let players = snapshot.value as? [String] else {
                print("Failed to get players array")
                return
            }
            
            // 获取当前玩家在players数组中的索引
            guard let playerIndex = players.firstIndex(of: self.playerID) else {
                print("Current player not found in players array")
                return
            }
            
            // 检查该角色是否已被选择
            self.ref.child("rooms/\(self.roomID)/playerRoles").observeSingleEvent(of: .value) { snapshot in
                let playerRoles = snapshot.value as? [String: String] ?? [:]
                let isRoleSelected = playerRoles.values.contains(roleName) && playerRoles[self.playerID] != roleName
                
                if isRoleSelected {
                    self.showError("This Role Has Already Been Selected.")
                    return
                }
                
                // 获取当前的selectedRoles数组
                self.ref.child("rooms/\(self.roomID)/selectedRoles").observeSingleEvent(of: .value) { snapshot in
                    var selectedRolesArray: [String]
                    
                    // 处理多种可能的数据格式
                    if let existingArray = snapshot.value as? [String] {
                        selectedRolesArray = existingArray
                    } else if let existingDict = snapshot.value as? [String: String] {
                        // 如果是字典格式，转换为数组
                        selectedRolesArray = Array(repeating: "", count: max(players.count, existingDict.count))
                        for (key, value) in existingDict {
                            if let index = Int(key), index < selectedRolesArray.count {
                                selectedRolesArray[index] = value
                            }
                        }
                    } else {
                        // 创建新数组，大小与players数组一致
                        selectedRolesArray = Array(repeating: "", count: players.count)
                    }
                    
                    // 确保数组大小足够
                    while selectedRolesArray.count <= playerIndex {
                        selectedRolesArray.append("")
                    }
                    
                    // 使用事务确保原子性更新
                    self.ref.child("rooms/\(self.roomID)/selectedRoles").runTransactionBlock { currentData in
                        var dataToUpdate: [String]
                        
                        if var currentArray = currentData.value as? [String] {
                            // 确保数组足够大
                            while currentArray.count <= playerIndex {
                                currentArray.append("")
                            }
                            
                            // 更新选择
                            currentArray[playerIndex] = roleName
                            dataToUpdate = currentArray
                        } else {
                            // 如果不是数组，创建新数组
                            dataToUpdate = Array(repeating: "", count: playerIndex)
                            dataToUpdate.append(roleName)
                            
                            // 确保数组大小与players相同
                            while dataToUpdate.count < players.count {
                                dataToUpdate.append("")
                            }
                        }
                        
                        currentData.value = dataToUpdate
                        return TransactionResult.success(withValue: currentData)
                    }
                    
                    // 更新playerRoles映射
                    self.ref.child("rooms/\(self.roomID)/playerRoles/\(self.playerID)").setValue(roleName)
                    self.currentPlayerSelectedRole = roleName
                }
            }
        }
    }

    func deselectRole(roleName: String) {
        // 首先获取players数组，确定当前玩家的索引
        ref.child("rooms/\(roomID)/players").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let players = snapshot.value as? [String] else {
                print("Failed to get players array")
                return
            }
            
            // 获取当前玩家在players数组中的索引
            guard let playerIndex = players.firstIndex(of: self.playerID) else {
                print("Current player not found in players array")
                return
            }
            
            // 使用事务原子性更新selectedRoles
            self.ref.child("rooms/\(self.roomID)/selectedRoles").runTransactionBlock { currentData in
                if var selectedRoles = currentData.value as? [String], playerIndex < selectedRoles.count {
                    // 将该位置设置为空字符串，而不是删除
                    selectedRoles[playerIndex] = ""
                    currentData.value = selectedRoles
                }
                return TransactionResult.success(withValue: currentData)
            }
            
            // 移除playerRoles中的映射
            self.ref.child("rooms/\(self.roomID)/playerRoles/\(self.playerID)").removeValue()
            self.currentPlayerSelectedRole = nil
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return script.roles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoleCell", for: indexPath) as! RoleCell
        let roleName = script.roles[indexPath.row]
        cell.roleLabel.text = roleName

        // 根据角色的选中状态，设置按钮的状态
        let isSelected = selectedRoles.contains(roleName)
        cell.statusButton.isSelected = isSelected
        
        // 如果是当前玩家选择的角色，可以设置特殊样式
        let isCurrentPlayerRole = currentPlayerSelectedRole == roleName
        
        // 如果需要，可以在这里设置按钮的特殊样式以区分当前玩家所选角色和其他玩家所选角色
        // cell.statusButton.backgroundColor = isCurrentPlayerRole ? UIColor.green.withAlphaComponent(0.5) : UIColor.clear

        // 设置按钮的点击事件
        cell.buttonAction = { [weak self] in
            guard let self = self else { return }
            
            if isSelected {
                // 如果角色已被选中
                if isCurrentPlayerRole {
                    // 如果是当前玩家选择的角色，执行取消选中
                    self.deselectRole(roleName: roleName)
                } else {
                    // 如果是其他玩家选择的角色，提示错误
                    self.showError("This Role Has Already Been Selected.")
                }
            } else {
                // 角色未被选中，执行选中操作
                self.selectRole(roleName: roleName)
            }
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 100)
    }
}
