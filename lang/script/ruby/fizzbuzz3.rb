#! /usr/bin/env ruby
# coding: utf-8

a = Array.new( 101 )
for i in (1..100)
  a[i] = i
end

s = { 3 => "Fizz", 5 => "Buzz", 15 => "FizzBuzz" }
for n in [3, 5, 15]
  i = n
  f = s[n]
  while i <= 100
    a[i] = f
    i += n
  end
end
p a.pop( 100 )		# 先頭の要素（a[0]）を除く

