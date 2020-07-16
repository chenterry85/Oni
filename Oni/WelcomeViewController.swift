//Welcome Screen (with Sign In and Log In)

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("init")
    }
    
    @IBAction func clickLogIn(){
        let userInfo = "info"
        performSegue(withIdentifier: "choseLogIn", sender: userInfo)
    }
    
    @IBAction func clickSignUp(){
        performSegue(withIdentifier: "choseSignUp", sender: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choseLogIn"{
            print("perform segue")
        }
    }
}
