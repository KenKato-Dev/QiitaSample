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
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, QiitaData>
    private var datasource :UITableViewDiffableDataSource<Int, QiitaData>?
    @IBOutlet weak var tableView: UITableView!
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.binding()
        self.tableView.register(QiitaTableViewCell.nib(), forCellReuseIdentifier: QiitaTableViewCell.id)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //選択後戻った際に選択したcellを表示
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension ViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailedView = UIStoryboard(name: "DetailedView", bundle: nil).instantiateViewController(withIdentifier: "DetailedView") as! DetailedViewController
        detailedView.urlString = self.viewModel.qiita.dataArray[indexPath.row].url
        self.navigationController?.pushViewController(detailedView, animated: true)
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Task{
            do{
                try viewModel.pagination(row: indexPath.row)
            }catch{
                print(error.localizedDescription)
            }
        }
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
                    self?.showIndicator()
                case .loaded:
                    self?.apply()
                    self?.hideIndicator(true)
                case let .error(message):
                    self?.hideIndicator(true)
                    self?.showErrorMessageIfNeeded(message)
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
        snapshot.appendItems(viewModel.qiita.dataArray, toSection: 0)
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
        cell.userName.text = item.user.name
        cell.userName.adjustsFontSizeToFitWidth = true
        Task{
            do{
                cell.profileImage.image = try await viewModel.returnImageFromURL(urlString: item.user.profileImage)
            }catch{
                print(error.localizedDescription)
            }
        }
        cell.body.text = item.body
        return cell
    }
    private func showErrorMessageIfNeeded(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .default))
        present(alert, animated: true)
    }
    private func showIndicator() {
        indicatorBackView = UIView(frame: view.bounds)
        indicatorBackView.backgroundColor = .white
        indicatorBackView.alpha = 0.5
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(indicatorBackView)
        indicatorBackView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }
}
