package main

import (
	"errors"
	"fmt"
	"os"
)

// Single exit point pattern for main()
// This keeps main() clean and testable
func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// run contains all application logic
// Returns errors instead of calling os.Exit directly
func run() error {
	// Parse command-line arguments
	args := os.Args[1:]
	if len(args) < 1 {
		return errors.New("usage: program <arg>")
	}

	// Application logic here
	// All errors are returned, not handled with os.Exit
	if err := processInput(args[0]); err != nil {
		return fmt.Errorf("process input: %w", err)
	}

	return nil
}

func processInput(input string) error {
	// Implementation
	return nil
}
