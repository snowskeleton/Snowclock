//
//  Persistence.swift
//  Snowclock
//
//  Created by snow on 12/16/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static let test = PersistenceController(inMemory: true)

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let alarm = alarmMaker(context: viewContext)
            let f = Followup(context: viewContext)
            f.delay = 2
            f.id = UUID()
            f.alarm = alarm
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Snowclock_v_0_0_2")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save")
                try? container.persistentStoreCoordinator.destroyPersistentStore(at: URL(fileURLWithPath: container.name), type: NSPersistentStore.StoreType.sqlite)
                
            }
        }
    }
}
