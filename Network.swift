//
//  Network.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import Apollo
import RxSwift
import Foundation

class Network {
    
    var components: URLComponents {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host = "api.spacex.land"
        comp.path = "/graphql"
        return comp
    }
    
    static let shared = Network()
    
    private(set) lazy var apollo = ApolloClient(url: components.url!)
}

extension Network: ReactiveCompatible {}

extension Reactive where Base: Network {
    
    func fetch<Query: GraphQLQuery>(query: Query,
                                    cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                    context: UnsafeMutableRawPointer? = nil,
                                    queue: DispatchQueue = .main) -> Single<GraphQLResult<Query.Data>> {
        
        return .create { (single) -> Disposable in
            let cancellable = self.base.apollo.fetch(query: query, cachePolicy: cachePolicy, context: context, queue: queue) { (result) in                
                switch result {
                case let .success(result):
                    single(.success(result))
                case let .failure(error):
                    single(.error(error))
                }
            }
            return Disposables.create {
                cancellable.cancel()
            }
        }
        
    }
    
}
