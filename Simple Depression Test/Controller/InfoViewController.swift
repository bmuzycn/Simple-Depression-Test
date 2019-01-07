//
//  InfoViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 12/11/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit

class InfoViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alert()
    }
    func alert() {
        let infoNote = UIAlertController(title: "About Simple Depression Test", message:"Version 1.7 \n By Yu Zhang\n\n\nLast updated on 1/3/2019:\n- Add a slide-out menu for achives management.\n- Fixed some minor bugs.\n\nThanks to Daniel Cohen Gindi & Philipp Jahoda for their powerful CHARTS 3.0.\n\nFor more information: https://timyuzhang.com/ ", preferredStyle: UIAlertController.Style.alert)
        infoNote.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (alert) in
            self.performSegue(withIdentifier: "unwindToUserView", sender: self)
        }))
        present(infoNote, animated: true, completion: nil)
    }


}
