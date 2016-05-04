package main
import "fmt"
func main() {
	for i := 1; i <= 100; i++ {
		if 0 == (i % 15 ) {
			fmt.Print( "FizzBuzz" )
		} else if 0 == (i % 5 ) {
			fmt.Print( "Buzz" )
		} else if 0 == (i % 3 ) {
			fmt.Print( "Fizz" )
		} else {
			fmt.Print( i )
		}
		fmt.Print( " " )
	}
	fmt.Println( "" )
}



