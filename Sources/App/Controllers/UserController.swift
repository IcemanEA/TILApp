//
//  UserController.swift
//  
//
//  Created by Egor Ledkov on 12.08.2022.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "users")
    
        userRoutes.post(use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.get(":userID", use: getHandler)
        
        userRoutes.get(":userID", "acronyms", use: getAcronymsHandler)
    }
 
    private func createHandler(_ req: Request) throws ->EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        
        return user.save(on: req.db).map { user }
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }
}
