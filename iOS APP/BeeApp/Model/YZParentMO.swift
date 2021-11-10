//
//  YZParentMO.swift
//

import CoreData
//import YZLibraries

//MARK: - NSManagedObject
extension NSManagedObject {
    
    class func entityName() -> String {
        return "\(self.classForCoder())"
    }
    
    class func deleteRemovedObject(oldObjs: [NSManagedObject], newObjs:[NSManagedObject]){
        var setOld = Set(oldObjs)
        let setNew = Set(newObjs)
        
        setOld.subtract(setNew)
        
        for obj in setOld {
            (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext.delete(obj)
        }

        (YZAppConfig.appDelegate as! AppDelegate).saveContext()
    }
}

//MARK: - Protocol YZParentMO
protocol YZParentMO {
    
}

extension YZParentMO where Self: NSManagedObject {
    
    /***
     It will create a new entity in database by passing its name and return NSManagedObject
     */
    static func createNewEntity() -> Self {
        let object = NSEntityDescription.insertNewObject(forEntityName: Self.entityName(), into: (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext) as! Self
        return object
    }
    
    static func addUpdateEntity(key: String, value: String) -> Self {
        if let existingEntity = getExistingEntity(key, value: value) {
            return existingEntity
        }else{
             return createNewEntity()
        }
    }

    
    /// It will return an exsiting entity from database.
    ///
    /// - Parameters:
    ///   - key: Unique key name to identify record
    ///   - value: Unique valu to identify record
    /// - Returns: It will return exiting entity
    static func getExistingEntity(_ key: String, value: String) -> Self? {
        return fetchDataFromEntity(predicate: NSPredicate(format: "%K = %@", key, value), sortDescs: nil).first
    }
    
    /***
     It will return NSEntityDescription optional value, by passing entity name.
     */
    static func getExisting() -> NSEntityDescription? {
        let entityDesc = NSEntityDescription.entity(forEntityName: Self.entityName(), in: (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext)
        return entityDesc
    }

    /// It is class method.
    /// It will delete all records from the entity
    /// It is access directly using NSManagedObject class name.
    static func deleteAllRecords() {
        let entityDesc = getExisting()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDesc
        do {
            let resultsObj = try (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext.fetch(fetchRequest)
            for object in resultsObj as! [Self] {
                (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext.delete(object)
            }
            (YZAppConfig.appDelegate as! AppDelegate).saveContext()
        } catch let error as NSError {
            print(#function + " : " + error.localizedDescription)
        }
    }
    
    /***
     It will return an array of existing values from given entity name, with peredicate and sort description.
     */
    static func fetchDataFromEntity(predicate: NSPredicate? = nil, sortDescs: NSArray? = nil)-> [Self] {
        //let entityDesc = getExisting()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Self.entityName())
        //fetchRequest.entity = entityDesc
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescs = sortDescs {
            fetchRequest.sortDescriptors = sortDescs as? Array
        }
        
        do {
            let resultsObj = try (YZAppConfig.appDelegate as! AppDelegate).persistentContainer.viewContext.fetch(fetchRequest)
            if (resultsObj as! [Self]).count > 0 {
                return resultsObj as! [Self]
            }else{
                return []
            }
            
        } catch let error as NSError {
            print("Error in fetchedRequest : \(error.localizedDescription)")
            return []
        }
    }
}
