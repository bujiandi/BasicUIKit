//
//  Refreshing.swift
//  BasicUIKit
//
//  Created by 李招利 on 2018/11/23.
//  Copyright © 2018 李招利. All rights reserved.
//

import Basic
import Toast


extension HeaderRefreshView {
    
    
    public func bind(_ state:Store<HTTP.State>) {
        
        bind(state) {
            let header = $0.binder
            switch $0.new {
            case .success:
                if let content = header.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                fallthrough
            case .failure:
                header.endRefreshing()
            default : break
            }
        }
        
    }
    
    public func bind(_ state:Listener<HTTP.State>) {
        
        bind(state) {
            let header = $0.binder
            switch $0.new {
            case .success:
                if let content = header.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                fallthrough
            case .failure:
                header.endRefreshing()
            default : break
            }
        }
        
    }
    
    
    public func bind(_ state:Listener<NetGroup.State>) {
        
        bind(state) {
            let header = $0.binder
            switch $0.new {
            case .success:
                if let content = header.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                fallthrough
            case .failure:
                header.endRefreshing()
            default : break
            }
        }
        
    }
    
}

extension FooterRefreshView {
    
    
    public func bind(_ state:Store<HTTP.State>, noMoreData: @escaping () -> Bool) {
        bind(state) {
            let footer = $0.binder
            switch $0.new {
            case .success:
                if let content = footer.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                noMoreData() ? footer.endNoMoreData() : footer.endRefreshing()
            case .failure:
                footer.endRefreshing()
            default : break
            }
        }
        
    }
    
    public func bind(_ state:Listener<HTTP.State>, noMoreData: @escaping () -> Bool) {
        bind(state) {
            let footer = $0.binder
            switch $0.new {
            case .success:
                if let content = footer.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                noMoreData() ? footer.endNoMoreData() : footer.endRefreshing()
            case .failure:
                footer.endRefreshing()
            default : break
            }
        }
        
    }
    
    public func bind(_ state:Listener<NetGroup.State>, noMoreData: @escaping () -> Bool) {
        bind(state) {
            let footer = $0.binder
            switch $0.new {
            case .success:
                if let content = footer.contentView as? RefreshContentView {
                    content.lastRefreshDate = Date()
                }
                noMoreData() ? footer.endNoMoreData() : footer.endRefreshing()
            case .failure:
                footer.endRefreshing()
            default : break
            }
        }
        
    }
}

