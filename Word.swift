//
//  WordCell.swift
//  DictoCounter
//
//  Created by Raleigh Clemens on 3/20/21.
//

import Foundation
import os.log //logging system

class Word: NSObject, NSCoding {
    var word: String
    var count: Int
    var pinned: Bool
    
    init(word: String, count: Int){
        self.word = word
        self.count = count
        self.pinned = false
    }
    
    //MARK- Types
    struct PropertyKey{
        //each key stores a data value of Word
        static let word = "word"
        static let count = "count"
        static let pinned = "pinned"
    }
    
    //MARK- NSCoding
    //archive data
    func encode(with aCoder: NSCoder){
        aCoder.encode(word, forKey: PropertyKey.word)
        aCoder.encode(count, forKey: PropertyKey.count)
        aCoder.encode(pinned, forKey: PropertyKey.pinned)
    }
    
    
    //decode encoded data
    required convenience init?(coder aDecoder: NSCoder){ //? because it might return nil
        guard let word = aDecoder.decodeObject(forKey: PropertyKey.word) as? String
        else{
            os_log("unable to decode the word name for Word object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let count = aDecoder.decodeInteger(forKey: PropertyKey.count)
        let pinned = aDecoder.decodeBool(forKey: PropertyKey.pinned)
        
        self.init(word: word, count: count) //since it's a convenience init, it must call
        //the designated init
    }
    
    //MARK- Properties
    //file path where data is loaded and stored
    
    //MARK- Archiving Paths
    //access the path using Word.ArchiveURL.path outside of Word.swift
    static let DocumentsDictionary = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //uses FileManager's urls method to find the URL of this app's documents directory
    //this method returns a list of URLS, the first of which is optional and accesses this app's documents directory
    
    //create the file URL by appending "words" to the end of the document's URL
    static let ArchiveURL = DocumentsDictionary.appendingPathComponent("words")

    
}
