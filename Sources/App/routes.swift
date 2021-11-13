import Vapor

// Must conform to the Content protocol
// in order to return from a route.
struct Dog: Content {
    let id: Int
    var name: String
    var breed: String
}

struct NewDog: Content {
    let name: String
    let breed: String
}

var dogMap: [Int: Dog] = [:]

var lastId = 0

func addDog(name: String, breed: String) -> Dog {
    lastId += 1
    let dog = Dog(id: lastId, name: name, breed: breed)
    dogMap[lastId] = dog
    return dog
}

func setup() {
    _ = addDog(name: "Maisey", breed: "Treeing Walker Coonhound")
    _ = addDog(name: "Ramsay", breed: "Native American Indian Dog")
    _ = addDog(name: "Oscar", breed: "German Shorthaired Pointer")
    _ = addDog(name: "Comet", breed: "Whippet")
}

func routes(_ app: Application) throws {
    setup()

    app.get { _ in
        "It works!"
    }

    // The Content-Type header will automatically be set to "application/json".
    app.get("dog") { _ -> [Dog] in
        Array(dogMap.values)
    }

    app.get("dog", ":id") { req -> Dog in
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "missing id param")
        }

        if let dog = dogMap[id] {
            return dog
        } else {
            throw Abort(.notFound)
        }
    }

    app.post("dog") { req -> Dog in
        guard let byteBuffer = req.body.data else {
            throw Abort(.badRequest, reason: "invalid or missing body")
        }

        do {
            let newDog = try JSONDecoder().decode(NewDog.self, from: byteBuffer)
            return addDog(name: newDog.name, breed: newDog.breed)
        } catch {
            throw Abort(.badRequest, reason: "failed to decode body to Dog")
        }
    }
    
    app.put("dog", ":id") { req -> Dog in
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "missing id param")
        }
        
        // This creates a copy of the struct.
        guard var dog = dogMap[id] else {
            throw Abort(.notFound, reason: "no dog with id \(id) found")
        }
        
        guard let byteBuffer = req.body.data else {
            throw Abort(.badRequest, reason: "invalid or missing body")
        }

        do {
            let newDog = try JSONDecoder().decode(NewDog.self, from: byteBuffer)
            // Update the copied struct.
            dog.name = newDog.name
            dog.breed = newDog.breed
            
            // Update the value in dogMap.
            dogMap[id] = dog
            return dog
        } catch {
            throw Abort(.badRequest, reason: "failed to decode body to Dog")
        }
    }

    app.delete("dog", ":id") { req -> HTTPStatus in
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "missing id param")
        }
        
        let dog = dogMap.removeValue(forKey: id)
        return dog == nil ? .notFound : .ok
    }
}
