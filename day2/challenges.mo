import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";
//import Prim "mo:⛔";
import {compare} "mo:base/Nat";


actor {
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

     public query func average_array(array : [Int]) : async Int {
        
        var average : Int = 0;
        //var counter : Int = 0;        
        
        for (value in array.vals()){
          average := average + value;
          //counter += 1;
        };
       //average := average/counter;
       average := average/array.size();
       return average;
    };

//var size : Nat = 1 ;
//let x : [var Text] = Array.init<Text>(size, "");


    public query func count_character(t : Text, c1 : Char) : async Nat {

        var counter : Nat = 0;
        //var c3 : Text = Char.toText(c1);
        //var c3 : Text = c1[0];

        for (c2 : Char in t.chars()) {
          if (c2 == c1){
            counter += 1;
          };
        };
        return counter;

    };



    public query func factorial(n : Nat) : async Nat {
      
      func factorial_loop(m : Nat) : Nat {
        if (m == 0) {
          return 1;
        } else {
          return m * factorial_loop(m - 1);
      };
      };

      return factorial_loop(n);

    };

    


     public query func number_of_words(t : Text) : async Nat {
       
       var counter : Nat = 0;
      

        //var c3 : Text = Char.toText(c1);
        //var c3 : Text = c1[0];
        //let b = Char;
        //let c22 : Text = Text.fromchar(c2);
        //  var blank : Char = Nat32.toNat32Char(0xD800);
        //let blankchar32 = Char.toNat32("0xD800");
        //var blankchar : Char; //.toNat32(blank);
        let blank : Text = " ";


        for (c2 : Char in t.chars()) {
          //var test : Text = Text.fromchar(c2);
          if (c2 == blank){
            //var test : Text = Text.fromchar(c2);
            counter += 1;
          };
          //return counter;
        };
      
        return counter;        
        

    }; 
   


   public query func find_duplicates(a : [Nat]) : async [Nat] {
  
  /*
      let f = func (n : Nat, n1 : Nat) : Bool {
        if (n == n1) {
            return true
        } else {
            return false
        };
      };

      public func finditem(array : [Nat]) : async ?Nat {
        return(Array.find<Nat>(array, f));
      };

      var sorted_array : [Nat] = [0];
      for (n1 : Nat in a.vals()){
        if finditem(a){
          sorted_array.append(n1);
        }
      }
      return sorted_array;


    */
  
  
        var sorted_array : [Nat] = Array.sortInPlace(a, compare);//Array.sortInPlace(a, compare);

        return sorted_array;    

  }



  public query func convert_to_binary(n : Nat) : async Text {

      var binary : Text = " ";
      //binary := Nat.toText(n);
      return binary;
  }
};

