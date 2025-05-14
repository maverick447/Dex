//
//  FetchedPokemon.swift
//  Dex
//
//  Created by Prashanth Ramachandran on 5/6/25.
//

import Foundation // Bcos url object

struct FetchedPokemon: Decodable {
    let id: Int16
    let name: String
    let types: [String]
    let hp: Int16
    let attack: Int16
    let defense: Int16
    let specialAttack: Int16
    let specialDefense: Int16
    let speed: Int16
    let spriteURL: URL
    let shinyURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        // for the case = types
        enum TypeDictionaryKeys: CodingKey {
            case type
            
            enum TypeKeys: CodingKey {
                case name // This completes what needs to be done "types"
            }
        }
        
        enum statDictionaryKeys: CodingKey {
            case baseStat
//            case stat
//            
//            enum statKeys: CodingKey {
//                case name
//            }
        }
        
        enum spriteKeys: String, CodingKey {
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        // dicionary(keyed container) vs array (unkeyed container)
        // looking "types" https://jsonviewer.stack.hu/ it starts with types
        //further looking into types it seems like an array -> unkeyed container
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        // so now we are 1 step down {} and any number dictionaries
        while typesContainer.isAtEnd == false {
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        // Pidgeot
        // issue with birds where we there two types normal and flying
        // we would want to swap the two types by giving [0] == flying
        // and [1] == normal
        if decodedTypes.count == 2 && decodedTypes[0] == "normal" {
            decodedTypes.swapAt(0, 1)
        }
        
        self.types = decodedTypes
        
        // hp
        var decodedStats: [Int16] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.statDictionaryKeys.self)
            let stat = try statsDictionaryContainer.decode(Int16.self, forKey: .baseStat)
            decodedStats.append(stat)
        }
        self.hp = decodedStats[0]
        self.attack = decodedStats[1]
        self.defense = decodedStats[2]
        self.specialAttack = decodedStats[3]
        self.specialDefense = decodedStats[4]
        self.speed = decodedStats[5]
        
        // Sprite
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.spriteKeys.self, forKey: .sprites)
        self.spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        self.shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
    }
}
