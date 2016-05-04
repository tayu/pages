package main
import "fmt"
var (
	a = [101]string{}
	k = [3]int{ 3, 5, 15 }
	s = [3]string{ "Fizz", "Buzz", "FizzBuzz" }
)
func main() {
	for i := 1; i <= 100; i++ {
		a[i] = fmt.Sprint( i )
	}
	for i := 0; i < 3; i++ {
		n := k[i]
		t := s[i]
		for j := n; j <= 100; j += n {
			a[j] = t
		}
	}
	for i := 1; i <= 100; i++ {
		fmt.Print( a[i], " " )
	}
	fmt.Println( "" )
}
