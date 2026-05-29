//
//  BigPicController.swift
//  Scripts Distributor
//
//  Created by Wen Chen on 9/12/24.
//

import UIKit

class BigPicController: UIViewController {

    @IBOutlet weak var BigView: UIImageView!
    
    var bigView: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BigView.image = bigView
        // Do any additional setup after loading the view.
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
