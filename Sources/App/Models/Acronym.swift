//
//  Acronym.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Vapor
import Fluent

final class Acronym: Model {
    
    static let schema = "acronyms" // имя таблицы в базе данных
    
    @ID
    var id: UUID? // ключевое поле отмечается проперти враппером @ID
    
    @Field(key: "short")
    var short: String // поле в базе данных @Field это название поля в бд
    
    @Field(key: "long")
    var long: String // если поле может быть и нулл - то надо опциональный тип свойства и проперти врапер @OptionalField
    
    init () {} // обязательный пустой инициализатор!

    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }

}

// подписываем для работы с моделями JSON
extension Acronym: Content {}
