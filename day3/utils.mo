import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";
//import Prim "mo:⛔";
import {compare} "mo:base/Nat";


actor {

  func secondLargest(arr: [Int]) : Int {
      var largest = arr[0];
      var secondLargest = arr[0];
   
     
      for (num in array.vals()){ 
        if (num > largest) {
            secondLargest := largest;
            largest := num;
        } else if (num > secondLargest && num != largest) {
            secondLargest = num
        }
      }
   
      return secondLargest
  };


  // Challenge 2

    let f = func (n : Nat) : Bool {
        if (n % 2) {
            return false
        } else {
            return true
        };
    };

    public func remove_event(array : [Nat]) : async ?Nat {
        return(Array.filter<Nat>(array, f));
    };


  // Challenge 3

    public func drop<T>(l : Array<T>, n : Nat) : Array<T> {
        switch (l, n) {
            case (l_, 0) { l_ };
            case (null, _) { null };
            case ((?(h, t)), m) { drop<T>(t, m - 1) }
        }
    };



}
