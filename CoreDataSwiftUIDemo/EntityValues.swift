//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation
import CoreData

struct EntityValues {

    static let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sodales mi libero, eget aliquet nisl commodo eget. Sed mollis, tortor in facilisis viverra, purus velit pulvinar libero, vitae ornare eros ipsum vel orci. Suspendisse aliquet viverra diam, et consectetur sem imperdiet a. Pellentesque eget."
    var entityTitle: String
    var entityDescription: String
    var entityValue: Int16
    var entityImage: Data?
    var entityLabels: [String]

    let entityType: String

    mutating func fillWithDummayData() {
        self.entityTitle = String(EntityValues.loremIpsum.prefix(Int.random(in: 1...50)))
        self.entityDescription = String(EntityValues.loremIpsum.prefix(Int.random(in: 1...300)))
    }

    static func getEmptyEntity(ofType type: EntityType) -> EntityValues {
        var entityValues = EntityValues(entityTitle: "",
                                        entityDescription: "",
                                        entityValue: 0,
                                        entityImage: nil,
                                        entityLabels: [String](),
                                        entityType: type.rawValue)
        entityValues.fillWithDummayData()
        return entityValues
    }
}

extension Entity {

    func getValues() -> EntityValues {
        return EntityValues(entityTitle: self.entityTitle ?? "",
                            entityDescription: self.entityDescription ?? "",
                            entityValue: self.entityValue,
                            entityImage: self.entityImage,
                            entityLabels: self.entityLabels?.allObjects.compactMap({ ($0 as? EntityLabel)?.entityLabel }) ?? [String](),
                            entityType: self.entityType ?? EntityType.a.rawValue)
    }

    func fill(from entityValues: EntityValues) {
        //TODO: improve non-optimal update
        self.entityType = entityValues.entityType
        self.entityTitle = entityValues.entityTitle
        self.entityDescription = entityValues.entityDescription
        self.entityValue = entityValues.entityValue
        self.entityImage = entityValues.entityImage

        self.entityLabels?.forEach {
            self.managedObjectContext?.delete($0 as! NSManagedObject)
        }

        if self.entityType == EntityType.b.rawValue {
            self.entityLabels = NSSet(array: entityValues.entityLabels.compactMap({
                let entityLabel = EntityLabel(context: self.managedObjectContext!)
                entityLabel.entityLabel = $0
                return entityLabel
            }))
        }
    }
}
