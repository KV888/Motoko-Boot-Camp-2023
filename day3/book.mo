import Map "mo:base/HashMap";
import Text "mo:base/Text";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Array "mo:base/Array";


actor {

    type Title = Text;
    
    type Pages = Nat;

    let book = Map.HashMap<Title, Pages>(0, Text.equal, Text.hash);
    let bookarray : Array = [Text, Nat];

    public func create_book(name : Title, pages : Pages): async () {
        book.put(name, pages);
    };

    public query func lookup(name : Title) : async ?Pages {
        book.get(name)
    };




};
