//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import SwiftUI

struct EditEntity: View {
    @Environment(\.presentationMode) var presentationMode

    let isEditing: Bool
    @State var entityValues: EntityValues

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    @State private var labelToAdd: String = ""

    let onComplete: (EntityValues) -> Void
    var body: some View {
        Form {
            Section(header: Text("Entity Fields")) {
                TextField("Title", text: $entityValues.entityTitle) {
                    self.hideKeyboard()
                }
                TextField("Description", text: $entityValues.entityDescription) {
                    self.hideKeyboard()
                }

                Stepper("Value \(entityValues.entityValue)", value: $entityValues.entityValue, in: Int16(INT16_MIN)...Int16(INT16_MAX))

                Image(uiImage: inputImage ?? UIImage(data: entityValues.entityImage ?? Data()) ?? UIImage(named: "noImage") ?? UIImage())
                    .resizable()
                    .frame(width: 75, height: 75)
                    .onTapGesture {
                        self.showingImagePicker = true
                }
            }

            if entityValues.entityType == EntityType.b.rawValue {
                Section {
                    TextField("Add label", text: $labelToAdd) {
                        if self.labelToAdd.isEmpty == false {
                            self.entityValues.entityLabels.append(self.labelToAdd)
                            self.labelToAdd = ""
                        }
                        self.hideKeyboard()
                    }
                    List {
                        ForEach(entityValues.entityLabels, id: \.self) { label in
                            Text(label)
                        }
                        .onDelete(perform: deleteRecord)
                    }
                }
            }

            Section {
                if isEditing {
                    Button("Update") {
                        self.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    Button("Save") {
                        self.save()

                    }
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }

    private func save() {
        onComplete(entityValues)
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        entityValues.entityImage = inputImage.pngData()
    }

    func deleteRecord(at offsets: IndexSet) {
        offsets.forEach { index in
            self.entityValues.entityLabels.remove(at: index)
        }
    }
}

struct EditEntity_Previews: PreviewProvider {

    static var testEntity: Entity {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = Entity(context: moc)
        entity.entityTitle = "Lorem ipsum"
        entity.entityDescription = "Lorem ipsum"
        entity.entityValue = 42
        entity.entityImage = (UIImage(named: "noImage")?.pngData())!
        return entity
    }
    
    static var previews: some View {
        EditEntity(isEditing: false,
                   entityValues: EditEntity_Previews.testEntity.getValues(),
                   onComplete: { _  in })
    }
}
