import Map "mo:base/HashMap";
import Text "mo:base/Text";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Array "mo:base/Array";


actor {

    type Entry = {
        title: Text;
        pages: Nat;
    };

    let bookarray : Array = [Text, Nat];

    public func fromArray<bookarray>(xs : [bookarray]) : List<bookarray> {
        Array.foldRight<bookarray, List<bookarray>>(
            xs,
            nil<bookarray>(),
            func(x : bookarray, ys : List<bookarray>) : List<bookarray> {
                push<bookarray>(x, ys)
            }
        )
    };
    
    public func getbooks() : ?bookarray {    
          return bookarray;
    };

    public func addbook(x : Entry) : List<bookarray> {
          var newentry : List = func make<Entry>(x : Entry) : List<Entry>;
          List.append<Entry>(newentry, List<bookarray>);
    };
    

};
