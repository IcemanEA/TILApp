import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    let acronymController = AcronymController()
    try app.register(collection: acronymController)
    
    let userController = UserController()
    try app.register(collection: userController)
}
