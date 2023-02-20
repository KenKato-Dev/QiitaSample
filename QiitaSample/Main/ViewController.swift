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
        self.binding()
        self.tableView.register(QiitaTableViewCell.nib(), forCellReuseIdentifier: QiitaTableViewCell.id)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        guard let indexPath = tableView.indexPathForSelectedRow else {return}
//        tableView.deselectRow(at: indexPath, animated: true)
        Task{
            try await viewModel.fetchQiita()
        }
        tableView.reloadData()
    }


}
extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
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
                    self?.apply()
                    print("")
                case let .error(message):
                    print(message)
                }
            }.store(in: &cancellable)
        datasource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self]tableView, indexPath, item in
                self?.providedCell(tableView, at: indexPath, item: item)
            })
        Task{
            do{
                try await viewModel.fetchQiita()
            }catch{
                print(error.localizedDescription)
            }
        }
        apply()
    }
    func apply() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, QiitaData>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(viewModel.qiita.dataArray), toSection: 0)
        self.datasource?.defaultRowAnimation = .fade
        if let datasource{
            datasource.apply(snapshot, animatingDifferences: true)
        }else{
            datasource?.applySnapshotUsingReloadData(snapshot)
        }
    }
    func providedCell(_ tableView:UITableView, at indexPath:IndexPath, item:QiitaData)->UITableViewCell{
        let identifier = "QiitaTableViewCell"
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as? QiitaTableViewCell else {return UITableViewCell()}
        cell.title.text = item.title
        cell.createdDay.text = item.createdAt
        do{
            cell.profileImage.image = try viewModel.returnImageFromURL(urlString: item.user.profileImage)
        }catch{
            print(error.localizedDescription)
        }
        cell.body.text = item.body
        
        return cell
    }
}
