#! /usr/bin/env ruby

for i in (1..100)
  if 0 == (i % 15) then
    print "FuzzBuzz"
  elsif 0 == (i % 5) then
    print "Buzz"
  elsif 0 == (i % 3) then
    print "Fuzz"
  else
    print i
  end
  print " "
end
print "\n"

