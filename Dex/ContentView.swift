//
//  ContentView.swift
//  Dex
//
//  Created by Prashanth Ramachandran on 5/4/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // For search of pokemons based on the pokemon.id
    @FetchRequest<Pokemon>(//sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],// New API from CoreData
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default) private var pokedex//: FetchedResults
    
    @State private var searchText: String = ""
    @State private var filterByFavorites: Bool = false
    
    let fetcher = FetchService()
    
    // Filter of pokemons
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        // Search Predicate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        // Filter by Favorite predicate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d",true))
        }
        
        // Combine both predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        //NavigationView {
        // NavigationView is from the old recent is NavigationStack
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                // Text(pokemon.name ?? "No name")
                                // our instructor has taken the the latter
                                Text(pokemon.name!.capitalized)
                                    .fontWeight(.bold)
                                
                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            
                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
                                    Text(type.description.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(Color(type.capitalized))
                                        .clipShape(Capsule())
                                    
                                }
                            }
                        }
                    } //label: {
                      //  Text(pokemon.name ?? "no name")
                    //}
                }
            }// End of list
            .navigationTitle("Pokedex")
            .searchable(text: $searchText, prompt: "Find a Pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavorites) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                Text(pokemon.name ?? "no name")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        filterByFavorites.toggle()
                    } label: {
                        Label("Filter By Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                }
                ToolbarItem() {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }// ToolbarItem
            } // End toolbar
        } // NavigationStack
    } // End of body
    
    private func getPokemon() {
        Task {
            // for 1 < 152
            for id in 1..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    let pokemon = Pokemon(context: viewContext)
                    
                    // Datatypes are different as one is coming via the internet while we have format which is different
                    // this creates a object that is known to CoreData
                    
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
//                    if pokemon.id  % 2 == 0  {
//                        pokemon.favorite = true
//                    }
                    // CoreData saving
                    try viewContext.save()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
