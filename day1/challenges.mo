// Challenge # 1

  func multiply(n : Nat, m : Nat) : Nat = n * m;  

/* long version
  func multiply(n : Nat, m : Nat) : async Nat {
    var result : Nat = 0;
    result := n * m;
    return result;  
  };
*/

// Challenge # 2

  func volume(n : Nat) : Nat = n*n*n;

/* long version

  func volume(n : Nat) : async Nat {
    var cube : Nat = 0;
    cube := n^3;
    return cube;  
  };
*/

// Challenge #3

  func hours_to_minutes(n : Nat) : Nat = n * 60;


// Challenge #4
  var counter : Nat = 0;
  func set_counter(n : Nat) : async () {
    counter := n;
    return;
  };  

  func get_counter() : Nat = counter;
  

// Challenge #5

  func test_divide(n: Nat, m : Nat) : async Bool {
      if (n % m == 0){
        return true;
      } else
        return false;
  };


// Challenge #6

  func is_even(n : Nat) : async Bool {
    if (n % 2 == 0){
        return true;
      } else
        return false;    
  };
