//
//  LaunchListReactor.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import Apollo
import RxSwift
import ReactorKit

enum LoadState<A> {
    case loading
    case loaded(LoadState.ResultState)
    case failed(Error)
    
    enum ResultState {
        case empty
        case result(A)
    }
}

class LaunchListReactor: Reactor {
    
    typealias LaunchResult = (launches: [Launch], errors: [GraphQLError])
    typealias LaunchLoadState = LoadState<LaunchResult>
    
    enum Action {
        case fetchLaunches
    }
    
    enum Mutation {
        case setLaunchLoadingState(LaunchLoadState)
    }
    
    struct State {
        var launchState: LaunchLoadState = .loading
    }
    
    let initialState: State = .init()
    
    private let networker: Network
    
    init(networker: Network) {
        self.networker = networker
    }
    
}

extension LaunchListReactor {
    
    func mutate(action: LaunchListReactor.Action) -> Observable<LaunchListReactor.Mutation> {
        
        switch action {
        case .fetchLaunches:
            return networker.rx.fetch(query: LaunchListQuery())
                .asObservable()
                .compactMap {
                    let launches = $0.data?.launches?.compactMap { $0 } ?? []
                    let errors = $0.errors ?? []
                    return launches.isEmpty ? .setLaunchLoadingState(.loaded(.empty)) : .setLaunchLoadingState(.loaded(.result((launches, errors))))
            }
            .catchError { .just(.setLaunchLoadingState(.failed($0))) }
        }
        
    }
    
}


extension LaunchListReactor {
    
    func reduce(state: LaunchListReactor.State, mutation: LaunchListReactor.Mutation) -> LaunchListReactor.State {
        
        var newState = state
        
        switch mutation {
        case let .setLaunchLoadingState(loadingState):
            newState.launchState = loadingState
            return newState
        }
        
    }
    
}
