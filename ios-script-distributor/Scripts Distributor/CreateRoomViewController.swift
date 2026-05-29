import UIKit
import FirebaseDatabase

class CreateRoomViewController: UIViewController {

    @IBOutlet weak var roomIDLabel: UILabel!

    var roomID: String = ""
    var scriptMember: [String]?
    var scriptName: String?
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        createRoom()
    }

    func createRoom() {
        roomID = String(Int.random(in: 100000...999999))
        roomIDLabel.text = "Room ID: \(roomID)"
        ref.child("rooms/\(roomID)").setValue(["players": [], "selectedRoles": []])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRoleSelection" {
            if let destinationVC = segue.destination as? RoleSelectionViewController {
                destinationVC.roomID = roomID
                destinationVC.roles = scriptMember!
                destinationVC.scriptName = scriptName
            }
        }
    }
}
