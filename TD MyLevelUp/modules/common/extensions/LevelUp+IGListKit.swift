import IGListKit

extension CreditCardAccount: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? CreditCardAccount else { return false }
        return object.id == id && object.type == type && object.openDate == openDate
    }
}
