//
//  ViewController.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/15.
//

import UIKit
import Combine
enum Sections { //
case page(Int)
    var swctionstring:String{
        switch self{
            
        case let .page(int):
            return "\(int)ページ"
        }
    }
}

class ViewController: UIViewController {
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: ViewModel = .init(model: Model())
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, QiitaData>
    private var datasource :UITableViewDiffableDataSource<Int, QiitaData>?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        // Do any additional setup after loading the view.
    }


}
extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
}
extension ViewController{
    func binding(){
        viewModel.$stateOfViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stateOfViewModel in
                guard let stateOfViewModel = stateOfViewModel else{return}
                switch stateOfViewModel{
                case .loading:
                    print("")
                case .loaded:
                    print("")
                case let .error(message):
                    print(message)
                }
            }.store(in: &cancellable)
        datasource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self]tableView, indexPath, itemIdentifier in
                <#code#>
            })
        Task{
            do{
                try await viewModel.fetchQiita()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    func apply() {
        <#function body#>
    }
    func providedCell(_ tableView:UITableView, at indexPath:IndexPath, item:QiitaData)->UITableViewCell{
        let identifier = "QiitaDataCell"
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as? QiitaTableViewCell else {return UITableViewCell()}
        cell.title.text = item.title
        cell.createdDay.text = item.createdAt
        cell.profileImage
    }
}
