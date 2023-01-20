import Map "mo:base/HashMap";
import Text "mo:base/Text";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Principal  "mo:base/Principal";

actor {


// Challenge 1


  public query func unique(l : List): async List {
      var newList = List();
      for (item in l.size()) {
          // if(assert not newList.contains(item))
          if(!newList.contains(item)) {
          newList.append(item);
          }
      };
      return newList;
  };



// Challenge 2

  public query func reverseList(l : List) : async List {
      var result : List = [];

      for (item in l) {
          //   result.insert(item, atIndex : 0);
          result.insert(item, 0);
      };
      return result;
  };






// Challenge 3


  public shared ({ caller }) func is_anonymous() : async Bool {
        //let caller = getCaller();
      return caller.isAnonymous;
  };





// Challenge 4

  //let buf1 = Buffer.Buffer<Nat8>(32);

  public query func find_in_buffer(buf : Buffer,  val: T) : async ?Int {
      for (i in 0..buf.length) {
          if(buf[i] == val) {
          return Some(i);
          };
      };
      return Null;
  };



// Challenge 5

  public query get_usernames() : async [(Principal, Text)] {

      stable var usertuples : [(Principal, Text)] = [];
      usertuples := Iter.toArray(usernames.entries());
      return usertuples;
  };


 
}   
