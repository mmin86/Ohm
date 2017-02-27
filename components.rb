require 'prime'

require_relative 'helpers'

class Ohm
  include Helpers
  # These lambdas are executed during Ohm#exec.
  COMPONENTS = {
    '!' => ->(a){factorial(a.to_i)},
    '#' => ->(a){(0..a.to_i).to_a},
    '$' => ->{@vars[:register]},
    '%' => ->(a, b){a.to_f % b.to_f},
    '&' => ->(a, b){a && b},
    '\'' => ->(a){a.to_i.chr},
    '(' => ->(a, b){return a, b},
    ')' => ->(a){a.is_a?(Array) ? a[0, a.length - 1] : (@stack = @stack[0, @stack.length]; nil)},
    '*' => ->(a, b){a.to_f * b.to_f},
    '+' => ->(a, b){a.to_f + b.to_f},
    ',' => ->(a){@printed = true; puts untyped_to_s(a)},
    '-' => ->(a, b){a.to_f - b.to_f},
    '/' => ->(a, b){a.to_f / b.to_f},
    '<' => ->(a, b){a.to_f < b.to_f},
    '=' => ->(a){@printed = true; puts untyped_to_s(a)},
    '>' => ->(a, b){a.to_f > b.to_f},
    '@' => ->(a){(1..a.to_f).to_a},
    'A' => ->{},
    'B' => ->(a, b){to_base(a.to_i, b.to_i)},
    'C' => ->(a, b){arr_else_str(a).concat(arr_else_str(b))},
    'D' => ->(a){return a, a},
    'E' => ->(a, b){untyped_to_s(a) == untyped_to_s(b)},
    'F' => ->{false},
    'G' => ->(a, b){(a.to_i..b.to_i).to_a},
    'H' => ->(a, b){a.push(arr_else_str(b))},
    'I' => ->{$stdin.gets.chomp},
    'J' => ->(a){arr_or_stack(a) {|a| a.join('')}},
    'K' => ->{},
    'L' => ->(a){@printed = true; print untyped_to_s(a)},
    'M' => ->{},
    'N' => ->(a, b){untyped_to_s(a) != untyped_to_s(b)},
    'O' => ->{},
    'P' => ->(a){Prime.entries(a.to_i)},
    'Q' => ->{},
    'R' => ->(a){arr_else_str(a).reverse},
    'S' => ->(a){arr_else_chars_join(a) {|a| a.sort}},
    'T' => ->{true},
    'U' => ->(a){arr_else_chars_join(a) {|a| a.uniq}},
    'V' => ->(a){(1..a.to_i).select {|n| a.to_i % n == 0}},
    'W' => ->{@stack = [@stack]; nil},
    'X' => ->{},
    'Y' => ->{},
    'Z' => ->{},
    '[' => ->(a){@stack[a]},
    '\\' => ->(a){!a},
    ']' => ->(a){a.is_a?(Array) ? a.flatten(1) : a},
    '^' => ->{@vars[:index]},
    '_' => ->{@vars[:value]},
    '`' => ->(a){untyped_to_s(a).ord},
    'a' => ->{},
    'b' => ->(a){to_base(a.to_i, 2)},
    'c' => ->(a, b){nCr(a.to_i, b.to_i)},
    'd' => ->(a){a.to_f * 2},  
    'e' => ->(a, b){nPr(a.to_i, b.to_i)},
    'f' => ->(a){fibonacci_upto(a.to_i)},
    'g' => ->(a, b){(a.to_i...b.to_i).to_a},
    'h' => ->{},
    'i' => ->{},
    'j' => ->(a, b){arr_or_stack(a) {|a| a.join(untyped_to_s(b))}},
    'k' => ->(a, b){arr_else_str(a).index(b)},
    'l' => ->(a){arr_else_str(a).length},
    'm' => ->(a){a.to_i.prime_division.map {|x| x[0]}},
    'n' => ->(a){a.to_i.prime_division.map {|x| x[1]}},
    'o' => ->(a){a.to_i.prime_division},
    'p' => ->(a){a.to_i.prime?},
    'q' => ->{},
    'r' => ->{},
    's' => ->{},
    't' => ->(a, b){from_base(a.to_i, b.to_i)},
    'u' => ->{},
    'v' => ->{},
    'w' => ->(a){[a]},
    'x' => ->(a){to_base(a.to_i, 16)},
    'y' => ->{},
    'z' => ->{},
    '{' => ->(a){a.is_a?(Array) ? a.flatten : a},
    '|' => ->(a, b){a || b},
    '}' => ->(a){(a.is_a?(Array) ? a.each_slice(1) : untyped_to_s(a).each_char).to_a},
    '~' => ->(a){-a.to_f},
    "\u00C7" => ->(a, b){x = arr_else_chars(a).each_cons(b.to_i); a.is_a?(String) ? x.map {|e| e.join('')} : x},
    "\u00FC" => ->{},
    "\u00E9" => ->(a){a.to_f % 2 == 0},
    "\u00E2" => ->{},
    "\u00E4" => ->{},
    "\u00E0" => ->{},
    "\u00E5" => ->{},
    "\u00E7" => ->{},
    "\u00EA" => ->{},
    "\u00EB" => ->{},
    "\u00E8" => ->(a){a.to_f % 2 == 1},
    "\u00EF" => ->{},
    "\u00EE" => ->{},
    "\u00EC" => ->{},
    "\u00C4" => ->{},
    "\u00C5" => ->{},
    "\u00C9" => ->{},
    "\u00E6" => ->{},
    "\u00C6" => {
      'C' => ->(a){Math.cos(a.to_f)},
      'D' => ->(a){a.to_f * (180 / Math::PI)},
      'E' => ->(a){a.to_f * (Math::PI / 180)},
      'L' => ->(a){Math.log(a.to_f)},
      'M' => ->(a){Math.log10(a.to_f)},
      'N' => ->(a){Math.log2(a.to_f)},
      'R' => ->(a, b){x = (a.to_f / b.to_f).to_r; return x.numerator, x.denominator},
      'S' => ->(a){Math.sin(a.to_f)},
      'T' => ->(a){Math.tan(a.to_f)},
      'c' => ->(a){Math.acos(a.to_f)},
      'l' => ->(a, b){Math.log(b.to_f) / Math.log(a.to_f)},
      's' => ->(a){Math.asin(a.to_f)},
      't' => ->(a){Math.atan(a.to_f)},
      'u' => ->(a, b){Math.atan2(b.to_f, a.to_f)},
    },
    "\u00F4" => ->{},
    "\u00F6" => ->(a){a.to_f != 0.0},
    "\u00F2" => ->{},
    "\u00FB" => ->{},
    "\u00F9" => ->{},
    "\u00FF" => ->{},
    "\u00D6" => ->(a){a.to_f == 0.0},
    "\u00DC" => ->{},
    "\u00A2" => ->(a){@vars[:register] = a}, # This doesn't have to go under GET since assignment still returns the value
    "\u00A3" => ->{},
    "\u00A5" => ->{},
    "\u20A7" => ->(a){untyped_to_s(a) == untyped_to_s(a).reverse},
    "\u0192" => ->(a){nth_fibonacci(a.to_i)},
    "\u00E1" => ->{},
    "\u00ED" => ->{},
    "\u00F3" => ->{},
    "\u00FA" => ->{},
    "\u00F1" => ->(a){fibonacci?(a.to_i)},
    "\u00D1" => ->{},
    "\u00AA" => ->(a, b){a[b.to_i]},
    "\u00BA" => ->(a){2 ** a.to_f},
    "\u2310" => ->(a){(a.is_a?(Array) ? a : [a]).permutation.to_a},
    "\u00AC" => ->(a){powerset(a)},
    "\u00BD" => ->(a){a.to_f / 2},
    "\u00BC" => ->{@vars[:counter]},
    "\u00A1" => ->{@vars[:counter] += 1; nil},
    "\u00AB" => ->{},
    "\u00BB" => ->{},
    "\u2502" => ->{},
    "\u2524" => ->{},
    "\u2561" => ->{},
    "\u2562" => ->{},
    "\u2556" => ->{},
    "\u2555" => ->{},
    "\u2563" => ->{},
    "\u2557" => ->{},
    "\u255D" => ->{},
    "\u255C" => ->{},
    "\u255B" => ->{},
    "\u2510" => ->{},
    "\u2514" => ->{},
    "\u2534" => ->(a){untyped_to_s(a).upcase},
    "\u252C" => ->(a){untyped_to_s(a).downcase},
    "\u251C" => ->{},
    "\u2500" => ->{},
    "\u253C" => ->{},
    "\u255E" => ->{},
    "\u255F" => ->{},
    "\u255A" => ->{},
    "\u2554" => ->{},
    "\u2569" => ->{},
    "\u2566" => ->{},
    "\u2560" => ->{},
    "\u2550" => ->{},
    "\u256C" => ->(a){arr_else_chars(a).sample},
    "\u2567" => ->{},
    "\u2568" => ->{},
    "\u2564" => ->{},
    "\u2565" => ->{},
    "\u2559" => ->{},
    "\u2558" => ->{},
    "\u2552" => ->{},
    "\u2553" => ->{},
    "\u256B" => ->(a){arr_else_chars_join(a) {|a| a.shuffle}},
    "\u256A" => ->{},
    "\u2518" => ->{},
    "\u250C" => ->{},
    "\u2588" => ->{},
    "\u2584" => ->{},
    "\u258C" => ->{},
    "\u2590" => ->{},
    "\u2580" => ->{},
    "\u03B1" => {
      'K' => ->{'`1234567890-=qwertyuiop[]\\asdfghjkl;\'zxcvbnm,./'},
      'k' => ->{'qwertyuiopasdfghjklzxcvbnm'},
      "\u00DF" => ->{('a'..'z').to_a.join('')}, # Heh. Alpha-beta.
    },
    "\u00DF" => ->{},
    "\u0393" => ->{},
    "\u03C0" => ->(a){Prime.take(a.to_i).last},
    "\u03A3" => ->(a){arr_or_stack(a) {|a| a.map(&:to_f).reduce(0, :+)}},
    "\u03C3" => ->(a, b){a.is_a?(Array) ? a.each_slice(b.to_i).to_a : untyped_to_s(a).scan(/.{1,#{b.to_i}}/)},
    "\u00B5" => ->(a){arr_or_stack(a) {|a| a.map(&:to_f).reduce(1, :*)}},
    "\u03C4" => ->{10},
    "\u03B4" => ->{},
    "\u03C6" => ->(a){a.prime_division.map {|x| 1 - (1.0 / x[0])}.reduce(a, :*).to_i},
    "\u03B5" => ->(a, b){arr_else_chars(a).include?(arr_else_str(b))},
    "\u2229" => ->{},
    "\u2261" => ->(a){return a, a, a},
    "\u00B1" => ->(a, b){a.to_f ** (1 / b.to_f)},
    "\u2265" => ->(a){a.to_f + 1},
    "\u2264" => ->(a){a.to_f - 1},
    "\u2320" => ->(a){a.to_f.ceil},
    "\u2321" => ->(a){a.to_f.floor},
    "\u00F7" => ->(a){1 / a.to_f},
    "\u2248" => ->(a){a.to_f.round},
    "\u00B0" => ->(a){10 ** a.to_f},
    "\u2219" => ->{},
    "\u00B7" => ->(a, b){a * b.to_i}, # Repeat string
    "\u221A" => ->(a){Math.sqrt(a.to_f)},
    "\u207F" => ->(a, b){a.to_f ** b.to_f},
    "\u00B2" => ->(a){a.to_f ** 2},
    "\u25A0" => ->{}
  }

  # When these components are run, the values given to them will only be retrieved from the stack instead of being popped.
  STACK_GET = %W(=)

  # When these components are run, their return value will be appended to the stack with a splat operator.
  MULTIPLE_PUSH = %W(D \u2261)

  # When these components are run, their return value will be appended to the stack even if it's nil.
  PUSH_NILS = %W(k)

  # These components mark the opening statement of a block.
  OPENERS = %W(? : \u2591 \u2592 \u2593)
end
