//
//  AcronymController.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Vapor
import Fluent

struct AcronymController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // задаем путь для все запросов ниже
        let acronymRoutes = routes.grouped("api", "acronyms")
        
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.post(use: createHandler)
        acronymRoutes.put(":acronymID", use: updateHandler)
        acronymRoutes.delete(":acronymID", use: deleteHandler)
        
        acronymRoutes.get(":acronymID", use: getHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("first", use: getFirstHandler)
        
    }
    // показать все
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    
    // показать выбранный
    func getHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)) // извлечение опционала
    }
    
    // создать новый
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map { acronym }
    }
    
    // обновить выбранный
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
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
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent) // покажет статус 204 No Content
            }
    }
    
    // поиск
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
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
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
}
