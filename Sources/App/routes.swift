import Vapor

// Must conform to the Content protocol
// in order to return from a route.
struct Dog: Content {
    let id: Int
    let name: String
    let breed: String
}

var dogMap: [Int: Dog] = [:]

var lastId = 0

func addDog(name: String, breed: String) {
    lastId += 1
    dogMap[lastId] = Dog(id: lastId, name: name, breed: breed)
}

func initialize() {
    addDog(name: "Maisey", breed: "Treeing Walker Coonhound")
    addDog(name: "Ramsay", breed: "Native American Indian Dog")
    addDog(name: "Oscar", breed: "German Shorthaired Pointer")
    addDog(name: "Comet", breed: "Whippet")
}

func routes(_ app: Application) throws {
    initialize()

    app.get { _ in
        "It works!"
    }

    // The Content-Type header will automatically be set to "application/json".
    app.get("dog") { _ -> [Dog] in
        Array(dogMap.values)
    }

    app.get("dog", ":id") { req -> Dog in
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }

        if let dog = dogMap[id] {
            return dog
        } else {
            throw Abort(.notFound)
        }
    }
}
