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
    typealias DiffableLaunchDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, LaunchListQuery.Data.Launch>
    
    var disposeBag = DisposeBag()
    
    enum Section {
        case images
    }
    
    private var dataSource: DiffableLaunchDataSource!
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        cv.register(LaunchCollectionViewCell.self, forCellWithReuseIdentifier: "LaunchCollectionViewCell")
        cv.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cv.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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

        reactor.state.map { $0.launches }
            .subscribe(onNext: { [weak self] in
                self?.configureDataSource(launches: $0)
            })
        .disposed(by: disposeBag)
        
    }
    
    private func configureDataSource(launches: [LaunchListQuery.Data.Launch]) {
        dataSource = DiffableLaunchDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, launch: Launch) -> UICollectionViewCell? in
            let cell: LaunchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LaunchCollectionViewCell", for: indexPath) as! LaunchCollectionViewCell
            cell.configure(with: launch.links)
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
        
        let section = NSCollectionLayoutSection(group: mainGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}
