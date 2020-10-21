//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import SwiftUI

enum EntityType: String {
    case a = "A"
    case b = "B"
}

struct EntityRow: View {
    @State var childSize: CGSize = .zero
    let entity: Entity
    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .center) {
                Image(uiImage: UIImage(data: self.entity.entityImage ?? Data()) ?? UIImage(named: "noImage") ?? UIImage())
                    .resizable()
                    .frame(width: 75, height: 75)


                if entity.entityType == EntityType.b.rawValue {
                    Text(String(self.entity.entityLabels?.allObjects.compactMap({ ($0 as? EntityLabel)?.entityLabel })
                        .joined(separator: "\n") ?? ""))
                    .frame(minWidth: 75,
                           idealWidth: 75,
                           maxWidth: 75,
                           minHeight: 75,
                           idealHeight: max(childSize.height, 75),
                           maxHeight: max(childSize.height, 75),
                           alignment: .center)
                        .multilineTextAlignment(.center)
                        .opacity(0.7)
                        .minimumScaleFactor(0.0001)
                }
            }

            .padding()

            Spacer()
            VStack {
                Text(self.entity.entityTitle ?? "")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Text(self.entity.entityDescription ?? "")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            )


            Spacer()
            Text("\(self.entity.entityValue)")
                .font(.body)
                .padding()

        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.childSize = preferences
        }
    }
}

struct EntityRow_Previews: PreviewProvider {

    static var testEntity: Entity {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = Entity(context: moc)
        entity.entityType = EntityType.b.rawValue
        entity.entityTitle = "Lorem ipsum"
        entity.entityDescription = "Lorem ipsum"
        entity.entityValue = 42
        entity.entityImage = (UIImage(named: "noImage")?.pngData())!
        let label1 = EntityLabel(context: moc)
        label1.entityLabel = "Lorem ipsum dolor sit amet"
        let label2 = EntityLabel(context: moc)
        label2.entityLabel = "Lorem ipsum dolor sit amet"
        entity.entityLabels = NSSet(array: [label1, label2])
        return entity
    }

    static var testBigEntity: Entity {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let entity = Entity(context: moc)
        entity.entityType = EntityType.b.rawValue
        entity.entityTitle = "Lorem ipsum dolor sit amet, consectetur tincidunt."
        entity.entityDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sodales mi libero, eget aliquet nisl commodo eget. Sed mollis, tortor in facilisis viverra, purus velit pulvinar libero, vitae ornare eros ipsum vel orci. Suspendisse aliquet viverra diam, et consectetur sem imperdiet a. Pellentesque eget."
        entity.entityValue = 42
        entity.entityImage = (UIImage(named: "noImage")?.pngData())!
        let label1 = EntityLabel(context: moc)
        label1.entityLabel = "Lorem ipsum dolor sit amet, consectetur tincidunt."
        let label2 = EntityLabel(context: moc)
        label2.entityLabel = "Lorem ipsum dolor sit amet, consectetur tincidunt."
        entity.entityLabels = NSSet(array: [label1, label2])
        return entity
    }

    static var previews: some View {
        Group {
            EntityRow(entity: EntityRow_Previews.testEntity)
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 375, height: 100))
                .previewDisplayName("Light scheme")

            EntityRow(entity: EntityRow_Previews.testEntity)
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light scheme")

            EntityRow(entity: EntityRow_Previews.testBigEntity)
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Light scheme")
        }
    }
}
