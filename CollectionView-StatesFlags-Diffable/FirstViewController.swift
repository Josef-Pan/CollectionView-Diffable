//
//  PushViewController.swift
//  CollectionView-StatesFlags-Diffable
//
//  Created by Josef Pan on 22/4/22.
//

import UIKit

/// First UIViewController of the UINavigationController
/// With only one button to push to the second UIViewController
class FirstViewController: UIViewController {
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let b2 = UIBarButtonItem(title:"Push", style:.plain, target:self, action:#selector(doPush(_:)))
        self.navigationItem.rightBarButtonItem = b2
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    @objc private func doPush(_ sender: Any){
        let vc = SecondViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
