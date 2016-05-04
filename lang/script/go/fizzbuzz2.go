package main
import "fmt"
func main() {
	for i := 1; i <= 100; i++ {
		s := ""
		if 0 == (i % 3) {
			s = "Fizz"
		}
		if 0 == (i % 5) {
			s = s + "Buzz"
		}
		if "" == s {
			fmt.Print( i )
		} else {
			fmt.Print( s )
		}
		fmt.Print( " " )
	}
	fmt.Println( "" )
}



