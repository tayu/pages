#! /usr/bin/env ruby

for i in (1..100)
  s = ""
  if 0 == (i % 3) then
    s = "Fizz"
  end
  if 0 == (i % 5) then
    s = s + "Buzz"
  end

  if "" == s then
    print i
  else
    print s
  end
  print " "
end
print "\n"

