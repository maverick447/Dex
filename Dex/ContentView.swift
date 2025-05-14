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
 
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
        
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
        //if pokedex.count < 2 {
        if all.isEmpty {
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokemon yet.\nFetch some Pokemon to get started!")
            } actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1) // the beginning
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            //NavigationView {
            // NavigationView is from the old recent is NavigationStack
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
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
                                    } // HStack
                                    
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
                                            
                                        } // ForEach
                                    } // HStack
                                } // VStack
                            } // NavigationLink
                            .swipeActions(edge: .leading) {
                                Button(pokemon.favorite ? "Remove from Favorites" :
                                        "Add to Favorites", systemImage: "star") {
                                    pokemon.favorite.toggle()
                                    // Save to data
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print("Error saving data: \(error)")
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                            //label: {
                            //  Text(pokemon.name ?? "no name")
                            //}
                        } // For each
                    }  footer: { // End of list
                        if all.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted\nFetch the rest of the Pokemon.")
                            } actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                    }// End of Section
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
                    PokemonDetail()
                        .environmentObject(pokemon)
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
                } // End toolbar
            } // NavigationStack
        } // if else
    } // End of body
    
    private func getPokemon(from idPassed: Int) {
        Task {
            // for 1 < 152
            for id in idPassed..<152 {
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
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL

                    pokemon.sprite = try await URLSession.shared.data(from: fetchedPokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: fetchedPokemon.shinyURL).0
                    // CoreData saving
                    try viewContext.save()
                // End of do
                }  catch {
                    print(error)
                }
            } // For  1..152
            
            storeSprites()
        } // Task
    } // Func End
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in all {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                    print("Sprites stored: \(pokemon.id): \(pokemon.name!.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
