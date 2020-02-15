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
import Foundation

class LaunchListReactor: Reactor {
    
    typealias LaunchResult = (launches: [Launch], errors: [GraphQLError])
    
    enum Action {
        case fetchLaunches
    }
    
    enum Mutation {
        case setLaunches(LaunchResult)
        case setFetchLaunchError(Error)
    }
    
    struct State {
        var launches: [Launch] = []
        var graphQLErrors: [GraphQLError] = []
        var launchFetchError: Error?
    }
    
    let initialState: State = .init()
    
}

extension LaunchListReactor {
    
    func mutate(action: LaunchListReactor.Action) -> Observable<LaunchListReactor.Mutation> {
        
        switch action {
        case .fetchLaunches:
            return Network.shared.rx.fetch(query: LaunchListQuery())
                .asObservable()
                .compactMap {
                    let launches = $0.data?.launches?.compactMap { $0 } ?? []
                    let errors = $0.errors ?? []
                    return .setLaunches((launches, errors))
            }
            .catchError { .just(Mutation.setFetchLaunchError($0)) }
            .observeOn(MainScheduler.instance)
        }
        
    }
    
}


extension LaunchListReactor {
    
    func reduce(state: LaunchListReactor.State, mutation: LaunchListReactor.Mutation) -> LaunchListReactor.State {
        
        var newState = state
        
        newState.launchFetchError = nil
        newState.graphQLErrors = []
        
        switch mutation {
        case let .setLaunches(launchResult):
            newState.launches = launchResult.launches
            newState.graphQLErrors = launchResult.errors
            return newState
        case let .setFetchLaunchError(error):
            newState.launchFetchError = error
            return newState
        }
        
    }
    
}
