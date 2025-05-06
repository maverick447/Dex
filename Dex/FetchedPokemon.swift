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
    let sprite: URL
    let shiny: URL
    
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
            case sprite = "frontDefault"
            case shiny = "frontShiny"
        }
//        case hp
//        case attack
//        case defense
//        case specialAttack
//        case specialDefense
//        case speed
//        case sprite
//        case shiny
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int16.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([String].self, forKey: .types)
//        self.hp = try container.decode(Int16.self, forKey: .hp)
//        self.attack = try container.decode(Int16.self, forKey: .attack)
//        self.defense = try container.decode(Int16.self, forKey: .defense)
//        self.specialAttack = try container.decode(Int16.self, forKey: .specialAttack)
//        self.specialDefense = try container.decode(Int16.self, forKey: .specialDefense)
//        self.speed = try container.decode(Int16.self, forKey: .speed)
//        self.sprite = try container.decode(URL.self, forKey: .sprite)
//        self.shiny = try container.decode(URL.self, forKey: .shiny)
    }
}
