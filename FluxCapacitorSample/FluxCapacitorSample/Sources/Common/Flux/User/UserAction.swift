//
//  UserAction.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation
import FluxCapacitor
import GithubKit
import RxSwift

final class UserAction: Actionable {
    typealias DispatchValueType = Dispatcher.User
    
    private let session: ApiSession
    private var disposeBag = DisposeBag()
    
    init(session: ApiSession = .shared) {
        self.session = session
    }
    
    func fetchUsers(withQuery query: String, after: String?) {
        invoke(.lastSearchQuery(query))
        if query.isEmpty { return }
        disposeBag = DisposeBag()
        invoke(.isUserFetching(true))
        let request = SearchUserRequest(query: query, after: after)
        session.rx.send(request)
            .subscribe(onNext: { [weak self] in
                self?.invoke(.addUsers($0.nodes))
                self?.invoke(.lastPageInfo($0.pageInfo))
                self?.invoke(.userTotalCount($0.totalCount))
            }, onDisposed: { [weak self] in
                self?.invoke(.isUserFetching(false))
            })
            .disposed(by: disposeBag)
    }
}
