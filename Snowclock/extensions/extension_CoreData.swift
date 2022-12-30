//
//  extension_CoreData.swift
//  Snowclock
//
//  Created by snow on 12/30/22.
//

import CoreData

public extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
}
