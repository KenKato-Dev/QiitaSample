//
//  ViewController.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/15.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: ViewModel = .init(model: Model())
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}
extension ViewController{
    func binding(){
        viewModel.$stateOfViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stateOfViewModel in
                guard let stateOfViewModel = stateOfViewModel else{return}
            }
    }
}
