//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import SwiftUI

enum SortOrder {
    case byTitle
    case byNumber
    case byEntityA
    case byEntityB
}

extension Entity {

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}

struct EntitiesList: View {
    @FetchRequest(entity: Entity.entity(), sortDescriptors: []) var entitites: FetchedResults<Entity>
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var sortOrder: SortOrder = .byTitle
    @State var isPresented = false
    @State var entityToAdd: EntityType = .a

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.sortOrder = .byTitle
                    }) {
                        Text("Title")
                            .fontWeight(sortOrder == .byTitle ? .bold : .regular)
                    }
                    Spacer()
                    Button(action: {
                        self.sortOrder = .byNumber
                    }) {
                        Text("Number")
                            .fontWeight(sortOrder == .byNumber ? .bold : .regular)
                    }
                    Spacer()
                    Button(action: {
                        self.sortOrder = .byEntityA
                    }) {
                        Text("A")
                            .fontWeight(sortOrder == .byEntityA ? .bold : .regular)
                    }
                    Spacer()
                    Button(action: {
                        self.sortOrder = .byEntityB
                    }) {
                        Text("B")
                            .fontWeight(sortOrder == .byEntityB ? .bold : .regular)
                    }
                    Spacer()
                }
                .padding()
                List {
                    ForEach(entitites.sorted(by: { first, second in
                        switch sortOrder {
                        case .byTitle:
                            return first.entityTitle ?? "" <= second.entityTitle ?? ""
                        case .byNumber:
                            return first.entityValue <= second.entityValue
                        case .byEntityA:
                            return first.entityType ?? "" <= second.entityType ?? ""
                        case .byEntityB:
                            return first.entityType ?? "" > second.entityType ?? ""
                        }
                    }), id: \.self) { entity in
                        NavigationLink(destination: EditEntity(isEditing: true,
                                                               entityValues: entity.getValues(),
                                                               onComplete: { entityValues  in

                                                                entity.fill(from: entityValues)
                                                                self.saveContext()
                                                                self.managedObjectContext.reset() // hack to force update
                        })) {
                            EntityRow(entity: entity)
                        }
                    }
                    .onDelete(perform: deleteEntity)
                }

                .sheet(isPresented: $isPresented) {
                    EditEntity(isEditing: false,
                               entityValues: EntityValues.getEmptyEntity(ofType: self.entityToAdd),
                               onComplete: { entityValues in

                                let entity = Entity(context: self.managedObjectContext)
                                entity.fill(from: entityValues)
                                self.saveContext()
                                self.isPresented = false
                    })
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.entityToAdd = .a
                        self.isPresented = true
                    }) { Text("Add A") }
                    Spacer()
                    Button(action: {
                        self.entityToAdd = .b
                        self.isPresented = true
                    }) { Text("Add B") }
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle(Text("Entities"), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func deleteEntity(at offsets: IndexSet) {
        offsets.forEach { index in
            let entity = self.entitites[index]
            self.managedObjectContext.delete(entity)
        }
        saveContext()
    }

    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}

struct EntitiesList_Previews: PreviewProvider {
    static var previews: some View {
        EntitiesList().environment(\.managedObjectContext,
                                   (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    }
}
