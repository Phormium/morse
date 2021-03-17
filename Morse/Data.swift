//
//  Data.swift
//  Morse
//
//  Created by Леонид Сафронов on 22.06.2020.
//  Copyright © 2020 Леонид Сафронов. All rights reserved.
//

import Foundation
import CoreData

struct SavedTranslation: Identifiable {
    var id = UUID()
    var absText:String
    var morseText:String
}

class Model: ObservableObject {
    @Published var data:[NSManagedObject] = []
    var appDelegate:AppDelegate
    let managedContext:NSManagedObjectContext
    
    init(appDelegate:AppDelegate) {
        self.appDelegate = appDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        loadData()
    }
    fileprivate func loadData() {}
}

class HistoryModel: Model {
    let maxSize = 25
    
    func addItem(abc: String, morse:String) {
        let entity =  NSEntityDescription.entity(forEntityName: "History", in: managedContext)
        
        let newNote = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        newNote.setValue(abc, forKey: "abcText")
        newNote.setValue(morse, forKey: "morseText")
        data.append(newNote)
        if data.count > maxSize {
            removeItem()
        }
        saveData()
    }
    
    func getData() -> [SavedTranslation] {
        var result:[SavedTranslation] = []
        for d in data {
            result.append(SavedTranslation(absText: d.value(forKey: "abcText") as? String ?? "", morseText: d.value(forKey: "morseText") as? String ?? ""))
        }
        return result.reversed()
    }

    func removeItem() {
        while data.count > maxSize {
            let deleteNode = data.remove(at: 0)
            managedContext.delete(deleteNode)
        }
    }

    private func saveData() {
        do {
            try managedContext.save()
        } catch {
            print("Save error")
        }
    }

    override func loadData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"History")
        
        var fetchedResults:[NSManagedObject] = []
        do {
            fetchedResults = try (managedContext.fetch(fetchRequest) as? [NSManagedObject] ?? [])
        } catch {
            print("Load error")
        }
        
        data = fetchedResults
    }
}

class SavedModel: Model {
    func addItem(abc: String, morse:String) {
        let entity =  NSEntityDescription.entity(forEntityName: "Saved", in: managedContext)
        
        let newNote = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        newNote.setValue(abc, forKey: "abcText")
        newNote.setValue(morse, forKey: "morseText")
        data.append(newNote)
        saveData()
    }
    
    func getData() -> [SavedTranslation] {
        var result:[SavedTranslation] = []
        for d in data {
            result.append(SavedTranslation(absText: d.value(forKey: "abcText") as? String ?? "", morseText: d.value(forKey: "morseText") as? String ?? ""))
        }
        return result.reversed()
    }

    func removeItem(at pos:Int) {
        let deleteNode = data.remove(at: data.count - 1 - pos)
        managedContext.delete(deleteNode)
        saveData()
    }

    private func saveData() {
        do {
            try managedContext.save()
        } catch {
            print("Save error")
        }
    }

    override func loadData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Saved")
        
        var fetchedResults:[NSManagedObject] = []
        do {
            fetchedResults = try (managedContext.fetch(fetchRequest) as? [NSManagedObject] ?? [])
        } catch {
            print("Load error")
        }
        
        data = fetchedResults
    }
}

