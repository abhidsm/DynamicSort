# DynamicSort

A Vapor 4 package to sort the query results dynamically. No need to hardcode the sort fields and directions on the query, instead pass the sort field and sort direction in the reuest URL as parameters.

## Setup 
Add the dependency to Package.swift:

~~~~swift
.package(url: "https://github.com/abhidsm/DynamicSort.git", from: "0.0.1")
~~~~

import DynamicSort library in Configure.swift:

~~~~swift
import DynamicSort
~~~~

## Usage
Use the `dynamicSort` method instead of sort in any query:

```swift
func fetchUsers(_ req: Request) throws -> EventLoopFuture<[User]> {
  return User.query(on: req.db).dynamicSort(req).all()
}
```
`dynamicSort` will look for `sort_field` and `sort_direction` parameters in the Request. If there are no parameters passed then it will skip the sort and return the query.

### Default Sort
We can pass the default sort_field and sort_direction to the `dynamicSort` method:
```swift
let field = "id"
let dir = "DESC"
.dynamicSort(req, field: field, dir: dir)
```
if the `field` and `dir` are `nil` then `dynamicSort` will look for the sort_field and sort_direction parameters in the Request.

### Sort Multiple Columns
We can combine the fields we need to sort and pass it to the `dynamicSort` method:
```swift
let field = "id+created_at"
let dir = "DESC"
.dynamicSort(req, field: field, dir: dir)
```

### Sort on Ambiguous Columns
A query with `join` will have columns from multiple tables. If some of the column names are same in other tables, then we have to give the sort_field name with more clarity:
```swift
let field = "users.id+users.created_at"
let dir = "DESC"
.dynamicSort(req, field: field, dir: dir)
```

We can sort based on the join table columns as well:
```swift
let field = "users.id+profiles.created_at"
let dir = "DESC"
.dynamicSort(req, field: field, dir: dir)
```

## Support
Please star the Github repo if you are using this library, that will give me some idea about the reach. Feel free to contribute if you find any other scenario this library should support. Thanks :)
