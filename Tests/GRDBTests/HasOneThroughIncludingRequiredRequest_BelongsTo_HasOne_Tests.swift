import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

private typealias Book = HasOneThrough_BelongsTo_HasOne_Fixture.Book
private typealias Library = HasOneThrough_BelongsTo_HasOne_Fixture.Library
private typealias LibraryAddress = HasOneThrough_BelongsTo_HasOne_Fixture.LibraryAddress

class HasOneThroughIncludingRequiredRequest_BelongsTo_HasOne_Tests: GRDBTestCase {
    
    func testSimplestRequest() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            let graph = try Book
                .including(required: Book.libraryAddress)
                .fetchAll(db)
            
            assertEqualSQL(lastSQLQuery, """
                SELECT "books".*, "libraryAddresses".* \
                FROM "books" \
                JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                """)

            assertMatch(graph, [
                (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                ])
        }
    }
    
    func testLeftRequestDerivation() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                // filter before
                let graph = try Book
                    .filter(Column("title") != "Walden")
                    .including(required: Book.libraryAddress)
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    WHERE ("books"."title" <> 'Walden')
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
            
            do {
                // filter after
                let graph = try Book
                    .including(required: Book.libraryAddress)
                    .filter(Column("title") != "Walden")
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    WHERE ("books"."title" <> 'Walden')
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
            
            do {
                // order before
                let graph = try Book
                    .order(Column("title").desc)
                    .including(required: Book.libraryAddress)
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    ORDER BY "books"."title" DESC
                    """)

                assertMatch(graph, [
                    (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    ])
            }
            
            do {
                // order after
                let graph = try Book
                    .including(required: Book.libraryAddress)
                    .order(Column("title").desc)
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    ORDER BY "books"."title" DESC
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    ])
            }
        }
    }
    
    func testMiddleRequestDerivation() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                let middleAssociation = Book.library.filter(Column("name") != "Secret Library")
                let association = Book.hasOne(Library.address, through: middleAssociation)
                let graph = try Book
                    .including(required: association)
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON (("libraries"."id" = "books"."libraryId") AND ("libraries"."name" <> 'Secret Library')) \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
            
            do {
                // TODO: is it expected that order is not respected here?
                // Possible answer: ordering should be forbidden on associations, and always performed at the end of the full query.
                let middleAssociation = Book.library.order(Column("name").desc)
                let association = Book.hasOne(Library.address, through: middleAssociation)
                let graph = try Book
                    .including(required: association)
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                    """)

                assertMatch(graph, [
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
        }
    }
    
    func testRightRequestDerivation() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                let graph = try Book
                    .including(required: Book.libraryAddress.filter(Column("city") != "Paris"))
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON (("libraryAddresses"."libraryId" = "libraries"."id") AND ("libraryAddresses"."city" <> 'Paris'))
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
            
            do {
                let graph = try Book
                    .including(required: Book.libraryAddress.order(Column("city").desc))
                    .fetchAll(db)
                
                assertEqualSQL(lastSQLQuery, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    ORDER BY "libraryAddresses"."city" DESC
                    """)
                
                assertMatch(graph, [
                    (["isbn": "book2", "title": "The Fellowship of the Ring", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book3", "title": "Walden", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book4", "title": "Le Comte de Monte-Cristo", "libraryId": 1], ["city": "Paris", "libraryId": 1]),
                    (["isbn": "book5", "title": "Querelle de Brest", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book6", "title": "Eden, Eden, Eden", "libraryId": 2], ["city": "London", "libraryId": 2]),
                    (["isbn": "book7", "title": "Jonathan Livingston Seagull", "libraryId": 3], ["city": "Barcelona", "libraryId": 3]),
                    ])
            }
        }
    }
    
    func testRecursion() throws {
        struct Person : TableMapping {
            static let databaseTableName = "persons"
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "persons") { t in
                t.column("id", .integer).primaryKey()
                t.column("parentId", .integer).references("persons")
                t.column("childId", .integer).references("persons")
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let middleAssociation = Person.belongsTo(Person.self, using: ForeignKey([Column("parentId")]))
                let rightAssociation = Person.hasOne(Person.self, using: ForeignKey([Column("childId")]))
                let association = Person.hasOne(rightAssociation, through: middleAssociation)
                let request = Person.including(required: association)
                try assertEqualSQL(db, request, """
                    SELECT "persons1".*, "persons3".* \
                    FROM "persons" "persons1" \
                    JOIN "persons" "persons2" ON ("persons2"."id" = "persons1"."parentId") \
                    JOIN "persons" "persons3" ON ("persons3"."childId" = "persons2"."id")
                    """)
            }
        }
    }
    
    func testLeftAlias() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                // alias first
                let bookRef = TableReference(alias: "a")
                let request = Book.all()
                    .referenced(by: bookRef)
                    .filter(Column("title") != "Walden")
                    .including(required: Book.libraryAddress)
                try assertEqualSQL(db, request, """
                    SELECT "a".*, "libraryAddresses".* \
                    FROM "books" "a" \
                    JOIN "libraries" ON ("libraries"."id" = "a"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    WHERE ("a"."title" <> 'Walden')
                    """)
            }
            
            do {
                // alias last
                let bookRef = TableReference(alias: "a")
                let request = Book
                    .filter(Column("title") != "Walden")
                    .including(required: Book.libraryAddress)
                    .referenced(by: bookRef)
                try assertEqualSQL(db, request, """
                    SELECT "a".*, "libraryAddresses".* \
                    FROM "books" "a" \
                    JOIN "libraries" ON ("libraries"."id" = "a"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id") \
                    WHERE ("a"."title" <> 'Walden')
                    """)
            }
            
            do {
                // alias with table name (TODO: port this test to all testLeftAlias() tests)
                let bookRef = TableReference(alias: "books")
                let request = Book.all()
                    .referenced(by: bookRef)
                    .including(required: Book.libraryAddress)
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                    """)
            }
        }
    }
    
    func testMiddleAlias() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                let libraryRef = TableReference(alias: "a")
                let association = Book.hasOne(Library.address, through: Book.library.referenced(by: libraryRef))
                let request = Book.including(required: association)
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" "a" ON ("a"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "a"."id")
                    """)
            }
            do {
                // alias with table name
                let libraryRef = TableReference(alias: "libraries")
                let association = Book.hasOne(Library.address, through: Book.library.referenced(by: libraryRef))
                let request = Book.including(required: association)
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                    """)
            }
        }
    }
    
    func testRightAlias() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                // alias first
                let addressRef = TableReference(alias: "a")
                let request = Book
                    .including(required: Book.libraryAddress
                        .referenced(by: addressRef)
                        .filter(Column("city") != "Paris"))
                    .order(addressRef[Column("city")].desc)
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "a".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" "a" ON (("a"."libraryId" = "libraries"."id") AND ("a"."city" <> 'Paris')) \
                    ORDER BY "a"."city" DESC
                    """)
            }
            
            do {
                // alias last
                let addressRef = TableReference(alias: "a")
                let request = Book
                    .including(required: Book.libraryAddress
                        .order(Column("city").desc)
                        .referenced(by: addressRef))
                    .filter(addressRef[Column("city")] != "Paris")
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "a".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" "a" ON ("a"."libraryId" = "libraries"."id") \
                    WHERE ("a"."city" <> 'Paris') \
                    ORDER BY "a"."city" DESC
                    """)
            }
            
            do {
                // alias with table name (TODO: port this test to all testRightAlias() tests)
                let addressRef = TableReference(alias: "libraryAddresses")
                let request = Book.including(required: Book.libraryAddress.referenced(by: addressRef))
                try assertEqualSQL(db, request, """
                    SELECT "books".*, "libraryAddresses".* \
                    FROM "books" \
                    JOIN "libraries" ON ("libraries"."id" = "books"."libraryId") \
                    JOIN "libraryAddresses" ON ("libraryAddresses"."libraryId" = "libraries"."id")
                    """)
            }
            
        }
    }
    
    func testLockedAlias() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                // alias left
                let bookRef = TableReference(alias: "LIBRARYADDRESSES") // Create name conflict
                let request = Book.including(required: Book.libraryAddress).referenced(by: bookRef)
                try assertEqualSQL(db, request, """
                    SELECT "LIBRARYADDRESSES".*, "libraryAddresses1".* \
                    FROM "books" "LIBRARYADDRESSES" \
                    JOIN "libraries" ON ("libraries"."id" = "LIBRARYADDRESSES"."libraryId") \
                    JOIN "libraryAddresses" "libraryAddresses1" ON ("libraryAddresses1"."libraryId" = "libraries"."id")
                    """)
            }
            
            do {
                // alias right
                let addressRef = TableReference(alias: "BOOKS") // Create name conflict
                let request = Book.including(required: Book.libraryAddress.referenced(by: addressRef))
                try assertEqualSQL(db, request, """
                    SELECT "books1".*, "BOOKS".* \
                    FROM "books" "books1" \
                    JOIN "libraries" ON ("libraries"."id" = "books1"."libraryId") \
                    JOIN "libraryAddresses" "BOOKS" ON ("BOOKS"."libraryId" = "libraries"."id")
                    """)
            }
        }
    }
    
    func testConflictingAlias() throws {
        let dbQueue = try makeDatabaseQueue()
        try HasOneThrough_BelongsTo_HasOne_Fixture().migrator.migrate(dbQueue)
        
        try dbQueue.inDatabase { db in
            do {
                let bookRef = TableReference(alias: "A")
                let addressRef = TableReference(alias: "a")
                let request = Book.including(required: Book.libraryAddress.referenced(by: addressRef)).referenced(by: bookRef)
                _ = try request.fetchAll(db)
                XCTFail("Expected error")
            } catch let error as DatabaseError {
                XCTAssertEqual(error.resultCode, .SQLITE_ERROR)
                XCTAssertEqual(error.message!, "ambiguous alias: A")
                XCTAssertNil(error.sql)
                XCTAssertEqual(error.description, "SQLite error 1: ambiguous alias: A")
            }
        }
    }
}