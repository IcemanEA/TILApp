import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    // показать все
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db).all()
    }
    
    // показать выбранный
    app.get("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)) // извлечение опционала
    }
    
    // создать новый
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        
        return acronym.save(on: req.db).map { acronym }
    }
    
    // обновить выбранный
    app.put("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        // полученный параметр из тела
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db)
        .unwrap(or: Abort(.notFound)).flatMap { acronym in // тут флэт как вложенность будущих вещей из поиска и внутри апдейта
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req.db).map { acronym } // тут сохраняем
        }
    }
    
    // удалить выбранный
    app.delete("api", "acronyms", ":acronymID") { req -> EventLoopFuture<HTTPStatus> in
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent) // покажет статус 204 No Content
            }
    }
    
    // поиск
    app.get("api", "acronyms", "search") { req -> EventLoopFuture<[Acronym]> in
        // параметры через, заданные череp ? - например term
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest) // ошибка 400 - не найдено
        }
        // поиск по одному полю
//        return Acronym.query(on: req.db)
//            .filter(\.$short == searchTerm) // обертка свойства через $
//            .all()
        
        // поиск по группе полей c условием OR
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
    }
    
    // первый элемент + сортировка
    app.get("api", "acronyms", "first") { req -> EventLoopFuture<Acronym> in
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}
