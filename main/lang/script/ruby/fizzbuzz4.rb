#! /usr/bin/env ruby

a = Array.new( 101 )
i = 3
while i <= 100
  a[i] = "Fizz"
  i += 3
end
i = 5
while i <= 100
  a[i] = a[i].to_s + "Buzz"
  i += 5
end
for i in (1..100)
  print (nil == a[i] ? i: a[i]), " " 
end
print "\n"

