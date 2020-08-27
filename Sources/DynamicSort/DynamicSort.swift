import Vapor
import Fluent

struct DynamicSort {
    enum SortDirection: String {
        case asc = "ASC"
        case desc = "DESC"
    }
}

extension QueryBuilder {
    func genericSort(_ req: Request, field: String? = nil, dir: String? = nil) -> Self {
        var fields: [String] = []
        var sortField: String? = nil
        if field != nil {
            if field!.contains("+") {
                fields = field!.split(separator: "+").map { String($0) }.compactMap { $0 }
            } else {
                sortField = field!
            }
        } else {
            guard let sortOn = try? req.query.get(String.self, at: "sort_field") else { return self }
            sortField = sortOn
        }
        
        let direction = sortDir(req, dir: dir)
        if fields.count > 0 {
            var query = self
            for field in fields {
                let sortField = DatabaseQuery.Field.custom(field)
                query = query.sort(sortField, direction)
            }
            return query
        } else {
            let field = DatabaseQuery.Field.custom(sortField!)
            return self.sort(field, direction)
        }
    }
    
    func sortDir(_ req: Request, dir: String? = nil) -> DatabaseQuery.Sort.Direction {
        var direction = DatabaseQuery.Sort.Direction.custom("invalid")
        var sortDirection: String? = nil
        if dir == nil {
            guard let sortDir = try? req.query.get(String.self, at: "sort_direction") else { return direction }
            sortDirection = sortDir
        } else {
            sortDirection = dir
        }
        do {
            if let safeValue = sortDirection, DynamicSort.SortDirection.init(rawValue: safeValue) == nil {
                throw Abort(.badRequest, headers: [:], reason: "\(sortDirection ?? "null") is not a valid \(DynamicSort.SortDirection.self) parameter")
            }
        } catch {
            return direction
        }
        direction = DatabaseQuery.Sort.Direction.ascending
        if sortDirection == DynamicSort.SortDirection.desc.rawValue {
            direction = DatabaseQuery.Sort.Direction.descending
        }
        return direction
    }
}
