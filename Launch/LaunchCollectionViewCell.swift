//
//  LaunchCollectionViewCell.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import UIKit
import Kingfisher

class LaunchCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        contentView.addConstraints(
            [
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ]
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with launchImageURLs: Launch.Link?) {
        let firstImageURLString = (launchImageURLs?.flickrImages?.first ?? "") ?? ""
        guard let url = URL(string: firstImageURLString) else { return }
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        imageView.kf.setImage(with: urlComponents?.url, placeholder: UIColor.lightGray.image(width: 100, height: 100), options: [.transition(.fade(0.1))])
    }
    
}
