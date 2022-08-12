//
//  CreateUser.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Fluent


struct CreateUser: Migration {
    
    private let schema = "users"
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .id()
            .field("name", .string, .required)
            .field("surname", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema).delete()
    }
}
