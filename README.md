# SwipeButton
swipe button for swift 

import Foundation
import UIKit

class ViewController: UIViewController {
    var swipeButton : SwipeButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
    }

    func setupUI() {
        if swipeButton == nil {
            self.swipeButton = SwipeButton(frame: CGRect(x:40, y:200, width: 300,height:50))
            swipeButton.isRightToLeft = true
            swipeButton.text = "すぐ買う"
            swipeButton.swipedText = "購入いたしました"

            self.view.addSubview(self.swipeButton)
        }
    }
}
