//
//  CreateAcronym.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Fluent

struct CreateAcronym: Migration {
    
    // метод на создание таблицы
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .id()
            .field("short", .string, .required) // название соответствует оберткам
            .field("long", .string, .required)
            .create()
    }
    
    // метод на удаление таблицы
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
}
