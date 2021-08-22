//
//  DBManager.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import Foundation
import SQLite3
class DBManager: NSObject {
    
    var documentsDirectory: String?
    var databaseFilename: String?
    var arrResults: NSMutableArray?
    var arrColumnNames: NSMutableArray?
    let databaseQueue = DispatchQueue(label: "com.vvk.ExpenseDatabase")
    var dbInsertionError = Bool()
    var affectedRows = 0
    var lastInsertedRowID: Int64 = 0
    
    init(dbFilename: String?) {
        
        super.init()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("paths[0]", paths[0])
        documentsDirectory =  paths[0].absoluteString
        print(documentsDirectory ?? "")
        databaseFilename = dbFilename
        copyDatabaseIntoDocumentsDirectory()
    }
    
    func copyDatabaseIntoDocumentsDirectory() {
        
        print("DBManager:: Filename: \(String(describing: databaseFilename))")
        let destinationPath = URL(fileURLWithPath: documentsDirectory!).appendingPathComponent(databaseFilename!).path
        if !FileManager.default.fileExists(atPath: destinationPath) {
            // The database file does not exist in the documents directory, so copy it from the main bundle now.
            let sourcePath = URL(fileURLWithPath: Bundle.main.resourcePath ?? "").appendingPathComponent(databaseFilename!).path
            do {
                try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
            } catch {
                
            }
            
        }else{
             print("DBManager::CopyDatabaseIntoDocumentsDirectory File exist")
        }
       
    }
    
    func setupDatabase() {
        
        if let filepath = Bundle.main.path(forResource: "DatabaseStructure", ofType: "txt") {
            do {
                
                var query: String?
                
                let contents = try String(contentsOfFile: filepath)
                
                let querys = contents.split(separator: ";")
                
                if(querys.count>0){
                    
                    for i in  0...querys.count-1 {

                        query = String(querys[i])
                        print(query ?? "")
                        let result = execute(query)
                        print(result ?? "")
                    }
                }
            } catch {
                // DatabaseStructure contents could not be loaded
            }
        } else {
            // DatabaseStructure.txt not found!
        }
    }
    
    func execute(_ query: String?) -> NSMutableArray? {
        
       print("DBManager:: execute")
        
        // Run the query and indicate that is executable.
        let result = runQueryCode(query: query!, isQueryExecutable: true)
        return result
    }
    
    func runQueryCode(query: String, isQueryExecutable queryExecutable: Bool) -> NSMutableArray? {
        var rowData: NSMutableArray!
        databaseQueue.sync(execute: {
            var db:OpaquePointer?
            let databasePathNew1 = URL(fileURLWithPath: documentsDirectory!).appendingPathComponent(self.databaseFilename!).path
            rowData = NSMutableArray()
        
            if arrResults != nil {
                arrResults!.removeAllObjects()
                arrResults = nil
            }
        
            arrResults = NSMutableArray()
            if arrColumnNames != nil {
                arrColumnNames!.removeAllObjects()
                arrColumnNames = nil
            }
            arrColumnNames = NSMutableArray()
            let openDatabaseResult = sqlite3_open(databasePathNew1, &db)
            
            if openDatabaseResult == SQLITE_OK {
                //sqlite3_busy_timeout(db, 5000)
                var compiledStatement: OpaquePointer?
                let prepareStatementResult = sqlite3_prepare_v2(db, query, -1, &compiledStatement, nil)
                
                if prepareStatementResult == SQLITE_OK {
                    if !queryExecutable {
                        var arrDataRow = NSMutableArray()
                        var dataPerRow =  NSMutableDictionary()
                        let totalCols = sqlite3_column_count(compiledStatement)
                        print("Total column count == ", totalCols)
                        for i in 0..<totalCols {
                            let col = sqlite3_column_name(compiledStatement, i);
                            // print(String(utf8String: col!))
                            dataPerRow.setValue("", forKey: String(utf8String: col!) ?? "")
                        }
                    while sqlite3_step(compiledStatement) == SQLITE_ROW {
                        dataPerRow = NSMutableDictionary()
                        arrDataRow = NSMutableArray()
                        let totalColumns = sqlite3_column_count(compiledStatement)
                        print("totalColumns == \(totalColumns)")
                        for i in 0..<totalColumns {
                            // Convert the column data) to text (characters).
                            let colName = String(cString: sqlite3_column_name(compiledStatement, i))
                            //print("column ",colName)
                            var dbDataAsChars:String
                            if(sqlite3_column_text(compiledStatement, i) == nil){
                                 dbDataAsChars = "(null)"
                            }else{
                                dbDataAsChars = String(cString: (sqlite3_column_text(compiledStatement, i))!)
                            }
                            // If there are contents in the currenct column (field) then add them to the current row array.
                            if dbDataAsChars != nil && !("\(dbDataAsChars)" == "(null)") {
                                // Convert the characters to string.
                                dataPerRow.setValue(String(utf8String: dbDataAsChars) ?? "", forKey: String(utf8String: colName) ?? "")
                                dataPerRow.setValue(String(utf8String: dbDataAsChars) ?? "", forKey: String(utf8String: colName) ?? "")
                                arrDataRow.add(String(utf8String: dbDataAsChars) ?? "")
                            } else {
                                arrDataRow.add("")
                                dataPerRow.setValue("", forKey: String(utf8String: colName) ?? "")
                            }
                            if arrColumnNames!.count != totalColumns {
                                if(sqlite3_column_text(compiledStatement, i)==nil){}
                                else{dbDataAsChars = String(cString: sqlite3_column_text(compiledStatement, i))
                                }
                                arrColumnNames!.add(String(utf8String: dbDataAsChars) ?? "")
                            }
                        }
                        if arrDataRow.count > 0 {
                            dataPerRow.setValue("1", forKey: "count")
                            rowData.add(dataPerRow)
                            arrResults!.add(arrDataRow)
                        }
                    }
                    if arrDataRow.count == 0 {
                        if dataPerRow == nil {
                            dataPerRow = NSMutableDictionary()
                        }
                        dataPerRow.setValue("0", forKey: "count")
                        rowData.add(dataPerRow)
                    }
                    
                }
                
                else{
                    let executeQueryResults = sqlite3_step(compiledStatement)
                    if executeQueryResults == SQLITE_DONE {
                        // Keep the affected rows.
                       //  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
                        affectedRows = Int(sqlite3_changes(db))
                        // Keep the last inserted row ID.
                        lastInsertedRowID = sqlite3_last_insert_rowid(db)
                        rowData.add([
                            "affectedRows": "\(affectedRows)",
                            "count": "\(lastInsertedRowID)"
                        ])
                        
                    }
                    else {
                        // If could not execute the query show the error message on the debugger.
                        rowData.add([
                            "error": String(utf8String: sqlite3_errmsg(db)) ?? "",
                            "count": "0"
                        ])
                    }

                }
                
                
            }else{
                rowData.add([
                    "error": String(utf8String: sqlite3_errmsg(db)) ?? "",
                    "count" : "0"
                ])
                print("db insertion issue found error")
                dbInsertionError = true
            }
             // Release the compiled statement from memory.
             sqlite3_finalize(compiledStatement);
        }
            // Close the database.
            print("close Database")
            sqlite3_close(db);
        });
        return rowData
           

    }
    
    func runSelectQuery(_ query: String?) -> NSArray? {
        
        let result = runQueryCode(query: query!, isQueryExecutable: false)
        
        if(result != nil && result!.count > 0){
            
            let obj = result?.firstObject as! NSObject
            if((obj.value(forKey: "count") as? NSString)!.integerValue > 0){
                return result
            }else{
                return nil
            }
        }else{
            
            return nil
        }
    }
    
    func getCategories() -> NSArray? {
        
        let query = "SELECT * FROM categories"
        let result = runSelectQuery(query)
        if result != nil {
            
            if result!.count > 0 {
                return result
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func getUser(username: String) -> NSDictionary? {
        
        let query = "SELECT * FROM users where username = '\(username)'"
        let result = runSelectQuery(query)
        if result != nil {
            
            if result!.count > 0 {
                return result?.firstObject as? NSDictionary
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    func createUser(username: String, passcode: String) {
        
        let insertQuery = "INSERT INTO users ('username','passcode') VALUES ('\(username)','\(passcode)')"
        let insertResult = execute(insertQuery)
        print(insertResult ?? "")
    }
    
    func validateUser(username: String, passcode: String) -> NSDictionary? {
        
        let query = "SELECT * FROM users where username = '\(username)' and passcode = '\(passcode)'"
        let result = runSelectQuery(query)
        if result != nil {
            
            if result!.count > 0 {
                return result?.firstObject as? NSDictionary
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
}
