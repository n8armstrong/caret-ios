//
//  CaretAPI.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class CaretAPI: NSObject {

  struct Static {
    static var sharedInstance = CaretAPI()
  }

  class var sharedInstance: CaretAPI {
    get { return Static.sharedInstance }
    set { Static.sharedInstance = newValue }
  }

  private lazy var entries = Resource<Entry>(name: "entries")


  // MARK: - Entries

  func getEntries(start: NSDate, to end: NSDate, completion: Resource<Entry>.CollectionResponse? = nil) {
    let format = "yyyy-MM-dd"
    let byRange = "\(start.stringWithFormat(format))," +
      "\(end.stringWithFormat(format))"

    entries.all(parameters: ["by_range": byRange]) { (entries) in
      Caret.stores.entries.create(entries ?? [])
      completion?(collection: entries)
    }
  }

  func getEntries(date: NSDate, completion: Resource<Entry>.CollectionResponse? = nil) {
    getEntries(date, to: date)
  }

  func updateEntry(entry: Entry, completion: Resource<Entry>.ObjectResponse? = nil) {
    entries.update(entry, parameters: nil) { (entry, error) in
      if error == nil {
        if let entry = entry {
          Caret.stores.entries.update(entry)
        }
      }
      completion?(object: entry, error: error)
    }
  }

  func deleteEntry(entry: Entry, completion: Resource<Entry>.ObjectResponse? = nil) {
    if let id = entry.entryID {
      entries.destroy(id, parameters: nil) { (entry, error) in
        if error == nil {
          if let entry = entry {
            Caret.stores.entries.remove(entry)
          }
        }
        completion?(object: entry, error: error)
      }
    }
  }

}
