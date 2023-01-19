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

};
