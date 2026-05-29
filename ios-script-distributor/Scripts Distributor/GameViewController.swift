import UIKit
import FirebaseDatabase
import PDFKit
import Foundation

class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var roomID: String = ""
    var playerID: String = ""
    var ref: DatabaseReference!
    
    var script: Script!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pdfContainerView: UIView!
    @IBOutlet weak var nextActButton: UIButton!  // 添加 IBOutlet
    
    var pdfView: PDFView!
    var playerRole: PlayerRole?
    var playerIDs: [String] = []
    
    var totalActs: Int = 0
    var acts: [Act] = []
    
    var clueStages: [ClueStage] = []
    var totalClueStages: Int = 0
    var currentClueStageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // 设置 tableView 的数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
        
        // 初始化玩家准备状态为false
        resetPlayerReadyStatus()
        
        // 初始化 PDFView
        setupPDFView()
        
        // 初始化 acts 和 totalActs
        acts = [script.acts.first!]
        totalActs = script.acts.count
        
        // 初始化 clueStages 和 totalClueStages
        clueStages = [script.clueStages.first!]
        totalClueStages = script.totalClueStages
        
        // 确保currentAct在Firebase中存在，如果不存在则初始化为1
        initializeCurrentAct()
        
        // 获取玩家的角色信息
        fetchPlayerRole()
        
        // 获取房间中的所有玩家 ID
        fetchPlayerIDs()
        
        // 监听新玩家加入
        listenForNewPlayers()
        
        // 自定义导航栏标题样式
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    func setupPDFView() {
        pdfView = PDFView(frame: pdfContainerView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfContainerView.addSubview(pdfView)
    }
    
    // 添加此方法确保currentAct在Firebase中被正确初始化
    func initializeCurrentAct() {
        ref.child("rooms/\(roomID)/currentAct").observeSingleEvent(of: .value) { [weak self] snapshot in
            if !snapshot.exists() {
                // 如果currentAct不存在，初始化为1
                self?.ref.child("rooms/\(self!.roomID)/currentAct").setValue(1)
                print("已初始化currentAct为1")
            } else {
                let actNumber = snapshot.value as? Int ?? 1
                print("获取到当前幕数: \(actNumber)")
            }
        }
    }
    
    func fetchPlayerRole() {
        ref.child("rooms/\(roomID)/playerRoles/\(playerID)").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            if let roleName = snapshot.value as? String {
                print("The Role of the Player is：\(roleName)")
                self.playerRole = PlayerRole(name: roleName)
                DispatchQueue.main.async {
                    // 设置导航栏标题为角色的显示名称
                    self.title = self.playerRole?.displayName
                    // 默认加载第一幕
                    self.loadPDF(for: self.script.acts.first!)
                    // 选中左侧列表的第一项
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            } else {
                print("Couldn't Access to Player's Role Information.")
                // 处理错误，例如显示提示信息
            }
        }
    }
    
    // 修改获取玩家ID的方法，确保能获取到所有平台的玩家
    func fetchPlayerIDs() {
        // 首先从playerRoles获取玩家ID
        ref.child("rooms/\(roomID)/playerRoles").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let playerRolesDict = snapshot.value as? [String: Any] {
                // 从playerRoles中获取所有玩家ID
                let playerIDsFromRoles = Array(playerRolesDict.keys)
                
                // 同时检查players数组，确保不会漏掉任何玩家
                self.ref.child("rooms/\(self.roomID)/players").observeSingleEvent(of: .value) { playersSnapshot in
                    if let playersArray = playersSnapshot.value as? [String] {
                        // 合并两个来源的玩家ID，并去重
                        var allPlayerIDs = Set(playerIDsFromRoles)
                        allPlayerIDs.formUnion(playersArray)
                        
                        // 更新playerIDs数组
                        self.playerIDs = Array(allPlayerIDs)
                        print("总共检测到\(self.playerIDs.count)个玩家: \(self.playerIDs)")
                        
                        // 开始监听玩家的准备状态
                        self.observePlayersReadyStatus()
                        // 监听当前幕的变化
                        self.observeCurrentAct()
                    } else {
                        // 如果players数组不存在，仅使用playerRoles中的ID
                        self.playerIDs = playerIDsFromRoles
                        print("仅从playerRoles检测到\(self.playerIDs.count)个玩家: \(self.playerIDs)")
                        
                        // 开始监听玩家的准备状态
                        self.observePlayersReadyStatus()
                        // 监听当前幕的变化
                        self.observeCurrentAct()
                    }
                }
            } else {
                print("无法获取玩家列表")
                // 尝试从players数组获取
                self.ref.child("rooms/\(self.roomID)/players").observeSingleEvent(of: .value) { playersSnapshot in
                    if let playersArray = playersSnapshot.value as? [String] {
                        self.playerIDs = playersArray
                        print("仅从players数组检测到\(self.playerIDs.count)个玩家: \(self.playerIDs)")
                        
                        // 开始监听玩家的准备状态
                        self.observePlayersReadyStatus()
                        // 监听当前幕的变化
                        self.observeCurrentAct()
                    } else {
                        print("无法获取任何玩家信息")
                    }
                }
            }
        }
    }
    
    // 为了确保Android玩家也被添加到playerIDs，添加一个额外的监听
    func listenForNewPlayers() {
        // 监听players数组的变化
        ref.child("rooms/\(roomID)/players").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let playersArray = snapshot.value as? [String] {
                // 找出新增的玩家ID
                let newPlayerIDs = Set(playersArray).subtracting(Set(self.playerIDs))
                if !newPlayerIDs.isEmpty {
                    print("检测到新玩家: \(newPlayerIDs)")
                    // 将新玩家添加到playerIDs
                    self.playerIDs.append(contentsOf: newPlayerIDs)
                }
            }
        }
        
        // 监听playerRoles的变化
        ref.child("rooms/\(roomID)/playerRoles").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            if let playerRolesDict = snapshot.value as? [String: Any] {
                // 找出新增的玩家ID
                let rolesPlayerIDs = Set(playerRolesDict.keys)
                let newPlayerIDs = rolesPlayerIDs.subtracting(Set(self.playerIDs))
                if !newPlayerIDs.isEmpty {
                    print("检测到新玩家(从roles): \(newPlayerIDs)")
                    // 将新玩家添加到playerIDs
                    self.playerIDs.append(contentsOf: newPlayerIDs)
                }
            }
        }
    }
    
    func loadPDF(for act: Act) {
        guard let role = playerRole else {
            print("玩家角色未确定")
            return
        }
        
        if let roleScriptsForRole = script.roleScripts[role.name],
           let scriptURLString = roleScriptsForRole[act.number],
           let pdfURL = URL(string: scriptURLString) {
            let session = URLSession.shared
            let downloadTask = session.dataTask(with: pdfURL) { [weak self] (data, response, error) in
                if let error = error {
                    print("下载 PDF 文件出错：\(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("未收到 PDF 数据")
                    return
                }

                DispatchQueue.main.async {
                    if let document = PDFDocument(data: data) {
                        self?.pdfView.document = document
                    } else {
                        print("无法创建 PDF 文档")
                    }
                }
            }

            downloadTask.resume()
        } else {
            print("未找到对应的 PDF 文件 URL")
        }
    }
    
    // MARK: - Actions

    @IBAction func nextActButtonTapped(_ sender: UIButton) {
        // 将玩家的准备状态更新到 Firebase
        ref.child("rooms/\(roomID)/playerReadyStatus/\(playerID)").setValue(true)
        
        // 禁用按钮，防止重复点击
        sender.isEnabled = false
        
        print("玩家 \(playerID) 已设置为准备就绪")
    }
    
    // 修复版本 - 改进网络恢复能力和Firebase连接处理
    func observePlayersReadyStatus() {
        // 使用.keepSynced(true)确保即使离线也能获取数据
        ref.child("rooms/\(roomID)/playerReadyStatus").keepSynced(true)
        
        // 监听Firebase连接状态
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            if let connected = snapshot.value as? Bool, connected {
                print("Firebase连接已恢复")
                // 连接恢复时重新检查状态
                self.checkReadyStatus()
            } else {
                print("Firebase连接已断开")
            }
        })
        
        // 主要的状态监听函数
        ref.child("rooms/\(roomID)/playerReadyStatus").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.checkReadyStatus(snapshot: snapshot)
        }
    }

    // 分离状态检查逻辑到单独函数
    func checkReadyStatus(snapshot: DataSnapshot? = nil) {
        // 如果没有提供snapshot，重新获取最新数据
        if snapshot == nil {
            ref.child("rooms/\(roomID)/playerReadyStatus").observeSingleEvent(of: .value) { [weak self] freshSnapshot in
                guard let self = self else { return }
                self.checkReadyStatus(snapshot: freshSnapshot)
            }
            return
        }
        
        guard let snapshot = snapshot else { return }
        
        // 初始假设所有人都已准备好
        var allPlayersReady = true
        var readyCount = 0
        var totalCount = 0
        
        // 添加调试输出，显示我们正在检查的数据
        print("检查玩家准备状态: \(snapshot.value ?? "nil")")
        
        // 确保有至少一个玩家
        if snapshot.childrenCount == 0 {
            print("没有检测到任何玩家准备状态")
            return
        }
        
        totalCount = Int(snapshot.childrenCount)
        
        // 检查每个玩家的准备状态
        for userSnapshot in snapshot.children {
            if let userSnapshot = userSnapshot as? DataSnapshot {
                let playerID = userSnapshot.key
                let isReady = userSnapshot.value as? Bool ?? false
                
                print("玩家 \(playerID) 准备状态: \(isReady)")
                
                if isReady {
                    readyCount += 1
                } else {
                    allPlayersReady = false
                    print("玩家 \(playerID) 尚未准备，等待中...")
                }
            }
        }
        
        print("所有玩家准备状态: \(allPlayersReady)，已准备: \(readyCount)/\(totalCount)")
        
        // 添加额外检查：确保readyCount确实等于totalCount
        if readyCount == totalCount && totalCount > 0 {
            print("确认所有玩家都已准备就绪，准备进入下一幕")
            self.advanceToNextAct(playerSnapshot: snapshot)
        } else {
            // 尚有玩家未准备，等待
            print("等待其他玩家准备，当前已准备: \(readyCount)/\(totalCount)")
        }
    }

    // 分离进入下一幕的逻辑到单独函数，并修改线索更新逻辑
    func advanceToNextAct(playerSnapshot: DataSnapshot) {
        // 获取当前的幕数并递增
        ref.child("rooms/\(roomID)/currentAct").observeSingleEvent(of: .value) { [weak self] actSnapshot in
            guard let self = self else { return }
            
            // 如果无法获取当前幕数，使用默认值1
            let currentActNumber = actSnapshot.exists() ? (actSnapshot.value as? Int ?? 1) : 1
            let nextActNumber = currentActNumber + 1
            
            print("当前幕: \(currentActNumber), 即将进入幕: \(nextActNumber)")
            
            // 重置所有玩家的准备状态
            for childSnapshot in playerSnapshot.children {
                if let childSnapshot = childSnapshot as? DataSnapshot {
                    let playerID = childSnapshot.key
                    self.ref.child("rooms/\(self.roomID)/playerReadyStatus/\(playerID)").setValue(false) { error, _ in
                        if let error = error {
                            print("重置玩家 \(playerID) 状态失败: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            // 更新当前幕数
            self.ref.child("rooms/\(self.roomID)/currentAct").setValue(nextActNumber) { error, _ in
                if let error = error {
                    print("更新幕数失败: \(error.localizedDescription)")
                } else {
                    print("成功更新幕数为: \(nextActNumber)")
                    
                    // 修改线索更新逻辑，使用幕数来判断，而不是线索阶段数
                    if nextActNumber <= self.script.acts.count {
                        // 找到与当前幕对应的线索阶段
                        if let nextStage = self.script.clueStages.first(where: { $0.number == nextActNumber }) {
                            if !self.clueStages.contains(where: { $0.number == nextStage.number }) {
                                self.clueStages.append(nextStage)
                                print("解锁新线索阶段: \(nextStage.name)")
                            }
                            self.currentClueStageNumber = nextActNumber  // 直接设置当前线索阶段为当前幕数
                            NotificationCenter.default.post(
                                name: NSNotification.Name("ClueStagesUpdated"),
                                object: nil,
                                userInfo: ["clueStages": self.clueStages]
                            )
                        } else {
                            print("无法找到对应幕数 \(nextActNumber) 的线索阶段")
                        }
                    } else {
                        print("已经是最后一幕，不再更新线索阶段")
                    }
                }
            }
        }
    }
    
    // 重置玩家准备状态
    func resetPlayerReadyStatus() {
        // 重置玩家准备状态
        ref.child("rooms/\(roomID)/playerReadyStatus/\(playerID)").setValue(false)
        print("已重置玩家 \(playerID) 的准备状态")
    }
    
    // 监听当前幕的变化
    func observeCurrentAct() {
        ref.child("rooms/\(roomID)/currentAct").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            guard let currentActNumber = snapshot.value as? Int else {
                print("无法获取当前的幕数")
                return
            }
            
            print("当前幕号更新为: \(currentActNumber)")
            
            DispatchQueue.main.async {
                // 根据幕的编号查找对应的 Act
                if let currentAct = self.script.acts.first(where: { $0.number == currentActNumber }) {
                    // 如果 acts 数组中还没有该幕，添加并刷新表格
                    if !self.acts.contains(where: { $0.number == currentAct.number }) {
                        self.acts.append(currentAct)
                        self.tableView.reloadData()
                    }
                    
                    // 加载当前幕的 PDF
                    self.loadPDF(for: currentAct)
                    
                    // 在表格中选中当前幕
                    if let index = self.acts.firstIndex(where: { $0.number == currentAct.number }) {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    }
                    
                    // 更新"下一幕"按钮的可见性
                    self.nextActButton.isHidden = currentActNumber >= self.totalActs
                    // 重置"下一幕"按钮
                    self.nextActButton.isEnabled = true
                    
                    // 当幕数变化时，也同步更新线索阶段
                    // 这确保即使是从其他设备推送的幕数更新，也能正确更新线索阶段
                    if let clueStage = self.script.clueStages.first(where: { $0.number == currentActNumber }) {
                        if !self.clueStages.contains(where: { $0.number == clueStage.number }) {
                            self.clueStages.append(clueStage)
                            print("从幕数更新中解锁新线索阶段: \(clueStage.name)")
                        }
                        self.currentClueStageNumber = currentActNumber
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ClueStagesUpdated"),
                            object: nil,
                            userInfo: ["clueStages": self.clueStages]
                        )
                    }
                } else {
                    print("未知的幕数：\(currentActNumber)")
                }
            }
        }
    }

    @IBAction func cluesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showCluesSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCluesSegue" {
            if let cluesVC = segue.destination as? CluesViewController {
                // 传递必要的数据
                cluesVC.playerRole = self.playerRole
                cluesVC.clueStages = self.clueStages  // 传递当前已解锁的线索阶段
                cluesVC.script = self.script
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFCell", for: indexPath)
        let act = acts[indexPath.row]
        cell.textLabel?.text = act.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
        cell.textLabel?.textAlignment = .center
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let act = acts[indexPath.row]
        // 加载并显示对应的 PDF 文件
        loadPDF(for: act)
    }

    deinit {
        // 移除所有观察者
        ref.removeAllObservers()
        NotificationCenter.default.removeObserver(self)
        print("GameViewController 已释放")
    }
}
