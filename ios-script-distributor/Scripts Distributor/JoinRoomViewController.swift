import UIKit
import FirebaseDatabase

class JoinRoomViewController: UIViewController {

    @IBOutlet weak var roomIDTextField: UITextField!

    var roomID: String = ""
    var scriptMember: [String]?
    var scriptName: String?
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(scriptMember)
        ref = Database.database().reference()
    }

    @IBAction func joinRoomTapped(_ sender: UIButton) {
        roomID = roomIDTextField.text ?? ""
        print("尝试加入房间，房间号：\(roomID)")
        
        guard !roomID.isEmpty else {
            showError("Please Enter the Room Number")
            return
        }

        ref.child("rooms/\(roomID)").observeSingleEvent(of: .value, with: { snapshot in
            print("收到房间数据，房间号：\(self.roomID)，存在：\(snapshot.exists())")
            if snapshot.exists() {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toRoleSelection", sender: self)
                }
            } else {
                self.showError("Room Doesn't Exist!")
            }
        }) { error in
            self.showError("出现错误：\(error.localizedDescription)")
            print("获取房间数据时出错：\(error.localizedDescription)")
        }
    }

    func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRoleSelection" {
            if let destinationVC = segue.destination as? RoleSelectionViewController {
                destinationVC.roomID = roomID
                destinationVC.roles = scriptMember
                destinationVC.scriptName = scriptName
            }
        }
    }
}
