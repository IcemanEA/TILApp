//
//  User.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Vapor
import Fluent

final class User: Model {
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "surname")
    var surname: String
    
    @Field(key: "username")
    var username: String
    
    // получаем все дочерние строки - $название поля из дочернего объекта
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    init () {}

    init(id: UUID? = nil, name: String, surname: String, username: String) {
        self.id = id
        self.name = name
        self.surname = surname
        self.username = username
    }
}

extension User: Content {}
