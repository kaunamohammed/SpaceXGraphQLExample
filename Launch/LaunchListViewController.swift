//
//  LaunchListViewController.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import ReactorKit

class LaunchListViewController: UIViewController, ReactorKit.View {
    
    typealias DiffableLaunchDataSource = UICollectionViewDiffableDataSource<Section, Launch>
    typealias DiffableLaunchDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Launch>
    
    var disposeBag = DisposeBag()
    
    enum Section {
        case images
    }
    
    private var dataSource: DiffableLaunchDataSource!
    
    private let activityIndicator = UIRefreshControl {
        $0.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        cv.register(LaunchCollectionViewCell.self, forCellWithReuseIdentifier: "LaunchCollectionViewCell")
        cv.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cv.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cv.refreshControl = activityIndicator
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        view.addSubview(collectionView)
        view.addConstraints(
            [
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
        
    }
    
    func bind(reactor: LaunchListReactor) {
        
        rx.viewDidLoad
            .map { Reactor.Action.fetchLaunches }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.launchState }
            .subscribe(onNext: { [weak self] launchState in
                
                switch launchState {
                    
                case let .loaded(outcome):
                    switch outcome {
                    case .empty:
                        self?.collectionView.refreshControl?.endRefreshing()
                    case let .result(launchResult):
                        self?.collectionView.refreshControl?.endRefreshing()
                        self?.configureDataSource(launches: launchResult.launches)
                    }
                case .loading:
                    self?.collectionView.refreshControl?.beginRefreshing()
                case let .failed(error):
                    self?.collectionView.refreshControl?.endRefreshing()
                    self?.showAlert(title: "An Error Occured", message: error.localizedDescription)
                }
                
            })
            .disposed(by: disposeBag)
        
    }
    
    private func configureDataSource(launches: [LaunchListQuery.Data.Launch]) {
        dataSource = DiffableLaunchDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, launch: Launch) -> UICollectionViewCell? in
            let cell: LaunchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LaunchCollectionViewCell", for: indexPath) as! LaunchCollectionViewCell
            guard let launchLinks = launch.links else { fatalError("Cannot construct LaunchCollectionViewCell") }
            cell.configure(with: launchLinks)
            return cell
        }
        
        let snapshot = snapshotForCurrentState(launches: launches)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func snapshotForCurrentState(launches: [Launch]) -> DiffableLaunchDataSourceSnapshot {
        var snapshot = DiffableLaunchDataSourceSnapshot()
        snapshot.appendSections([Section.images])
        snapshot.appendItems(launches)
        return snapshot
    }
    
    private func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alertController, animated: true)
    }
    
}

extension LaunchListViewController {
    
    func generateLayout() -> UICollectionViewLayout {
        
        let leadingBoxItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.7),
                heightDimension: .fractionalWidth(0.5)
            )
        )
        
        let trailingBoxItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            )
        )
        
        let trailingBoxGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.3),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitem: trailingBoxItem,
            count: 2
        )
        
        let mainGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitems: [leadingBoxItem, trailingBoxGroup]
        )
        
        let mainGroup2 = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitems: [trailingBoxGroup, leadingBoxItem]
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1)
            ),
            subitems: [mainGroup, mainGroup2]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}
