//
//  CreateAcronym.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Fluent

struct CreateAcronym: Migration {
    
    private let schema = "acronyms"
    
    // метод на создание таблицы
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema)
            .id()
            .field("short", .string, .required) // название соответствует оберткам
            .field("long", .string, .required)
            //.field("userID", .uuid, .required) - просто внутренний ключ Fluent
        // делаем отношение уже в базе!
            .field("userID", .uuid, .required, .references(User.schema, "id"))
            .create()
    }
    
    // метод на удаление таблицы
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(schema).delete()
    }
}
