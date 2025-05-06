//
//  Persistence.swift
//  Dex
//
//  Created by Prashanth Ramachandran on 5/4/25.
//

import CoreData

struct PersistenceController {
    // static u might have many objects that are PersistenceController but all of the
    // them point to a single PersistenceController (aka mimics Singleton pattern)
    static let shared = PersistenceController()
 
    // The thing that controls our sample preview database
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 1
        newPokemon.name = "bulbasaur"
        newPokemon.types = ["grass", "poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.sprite = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shiny = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        
        do {
            try viewContext.save()
        } catch {
            print(error)
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            
        }
        return result
    }()
    
    // The thing that holds the stuff(the DataBase)
    let container: NSPersistentContainer

    // Just a regular init function
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                //fatalError("Unresolved error \(error), \(error.userInfo)")
                print(error)
            }
        })
        // policy when a merge confict when data that is already there
        // There are 3 different schemes but the one we chose is to reject newly found data
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
