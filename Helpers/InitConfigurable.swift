//
//  InitConfigurable.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import Foundation

protocol InitConfigurable {
    init()
}

extension InitConfigurable {
    
    init(configure: (Self) -> Void) {
        self.init()
        configure(self)
    }
    
}

extension NSObject: InitConfigurable {}
