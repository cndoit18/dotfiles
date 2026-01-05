# Go Error Handling Patterns

Go uses explicit error values instead of exceptions. This file covers comprehensive error handling patterns.

## Basic Error Handling

### Always Check and Wrap Errors

```go
// ✅ GOOD: Wrap errors with context
func processUser(id string) error {
    user, err := getUser(id)
    if err != nil {
        return fmt.Errorf("get user %q: %w", id, err)
    }
    return validateUser(user)
}

// ❌ BAD: Returning raw errors without context
func processUser(id string) error {
    user, err := getUser(id)
    if err != nil {
        return err  // Loses context of where error occurred
    }
    return validateUser(user)
}
```

### Use %w for Error Wrapping

The `%w` verb wraps errors and allows unwrapping with `errors.Unwrap`:

```go
// ✅ GOOD: Use %w to wrap errors
func fetchData(id string) error {
    data, err := database.Get(id)
    if err != nil {
        return fmt.Errorf("fetch data for %q: %w", id, err)
    }
    return nil
}

// ❌ BAD: Use %v loses unwrapping capability
func fetchData(id string) error {
    data, err := database.Get(id)
    if err != nil {
        return fmt.Errorf("fetch data for %q: %v", id, err)
    }
    return nil
}
```

## Sentinel Errors

Define sentinel errors as package-level variables for specific error conditions:

```go
// Define sentinel errors at package level
var (
    ErrUserNotFound = errors.New("user not found")
    ErrInvalidInput = errors.New("invalid input")
    ErrUnauthorized = errors.New("unauthorized access")
    ErrTimeout      = errors.New("operation timed out")
)
```

### Matching Sentinel Errors with errors.Is

Use `errors.Is` to match sentinel errors, even if they've been wrapped:

```go
// ✅ GOOD: Use errors.Is for sentinel error matching
func getUserTimeZone(id string) (*time.Location, error) {
    tz, err := fetchUserTimeZone(id)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            // User doesn't exist. Use UTC as default.
            return time.UTC, nil
        }
        return nil, fmt.Errorf("get user timezone %q: %w", id, err)
    }
    return tz, nil
}

// ❌ BAD: Direct comparison doesn't work with wrapped errors
func getUserTimeZone(id string) (*time.Location, error) {
    tz, err := fetchUserTimeZone(id)
    if err != nil {
        if err == ErrUserNotFound {  // Won't match if error is wrapped!
            return time.UTC, nil
        }
        return nil, fmt.Errorf("get user timezone %q: %w", id, err)
    }
    return tz, nil
}
```

## Custom Error Types

For errors that need to carry additional information:

```go
// Custom error type
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %q: %s", e.Field, e.Message)
}

// Return custom error
func validateEmail(email string) error {
    if !strings.Contains(email, "@") {
        return &ValidationError{
            Field:   "email",
            Message: "must contain @ symbol",
        }
    }
    return nil
}

// Check for custom error type with errors.As
func processUserInput(user User) error {
    if err := user.Validate(); err != nil {
        var validationErr *ValidationError
        if errors.As(err, &validationErr) {
            // Handle validation error specifically
            log.Printf("Validation failed on field: %s", validationErr.Field)
            return fmt.Errorf("invalid user data: %w", err)
        }
        return fmt.Errorf("validate user: %w", err)
    }
    return nil
}
```

## Error Handling in main()

Use the single exit point pattern:

```go
// ✅ GOOD: Centralized exit logic (Uber Go compliant)
func main() {
    if err := run(); err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
}

func run() error {
    args := os.Args[1:]
    if len(args) != 1 {
        return errors.New("usage: program <filename>")
    }

    f, err := os.Open(args[0])
    if err != nil {
        return fmt.Errorf("open file: %w", err)
    }
    defer f.Close()

    data, err := io.ReadAll(f)
    if err != nil {
        return fmt.Errorf("read file: %w", err)
    }

    return processData(data)
}

// ❌ BAD: Multiple exit points and os.Exit calls scattered
func main() {
    args := os.Args[1:]
    if len(args) != 1 {
        fmt.Fprintf(os.Stderr, "usage: program <filename>\n")
        os.Exit(1)
    }

    f, err := os.Open(args[0])
    if err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }
    defer f.Close()

    data, err := io.ReadAll(f)
    if err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }

    if err := processData(data); err != nil {
        fmt.Fprintf(os.Stderr, "error: %v\n", err)
        os.Exit(1)
    }
}
```

## Multiple Errors

When you need to collect multiple errors:

```go
import "golang.org/x/sync/errgroup"

// ✅ GOOD: Use errgroup for concurrent operations
func processFiles(files []string) error {
    var g errgroup.Group

    for _, file := range files {
        file := file  // Capture loop variable
        g.Go(func() error {
            return processFile(file)
        })
    }

    if err := g.Wait(); err != nil {
        return fmt.Errorf("process files: %w", err)
    }
    return nil
}

// For collecting all errors (not just first)
type MultiError []error

func (m MultiError) Error() string {
    if len(m) == 0 {
        return "no errors"
    }
    if len(m) == 1 {
        return m[0].Error()
    }
    return fmt.Sprintf("%v (and %d more errors)", m[0], len(m)-1)
}

func validateUser(u User) error {
    var errs MultiError

    if u.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if u.Email == "" {
        errs = append(errs, errors.New("email is required"))
    }
    if u.Age < 0 {
        errs = append(errs, errors.New("age must be positive"))
    }

    if len(errs) > 0 {
        return errs
    }
    return nil
}
```

## Don't Panic

Reserve `panic` for truly exceptional situations:

```go
// ❌ BAD: Using panic for normal errors
func GetUser(id string) *User {
    user, err := fetchUser(id)
    if err != nil {
        panic(err)  // Don't panic in library code!
    }
    return user
}

// ✅ GOOD: Return errors
func GetUser(id string) (*User, error) {
    user, err := fetchUser(id)
    if err != nil {
        return nil, fmt.Errorf("fetch user %q: %w", id, err)
    }
    return user, nil
}

// ✅ ACCEPTABLE: Panic only for unrecoverable programming errors
func NewServer(config Config) *Server {
    if config.Port == 0 {
        panic("config.Port must be set")  // Programming error
    }
    return &Server{config: config}
}
```

## Defer for Cleanup

Always use defer for resource cleanup:

```go
// ✅ GOOD: Use defer for cleanup
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return fmt.Errorf("open file: %w", err)
    }
    defer f.Close()  // Cleanup happens automatically

    data, err := io.ReadAll(f)
    if err != nil {
        return fmt.Errorf("read file: %w", err)
    }

    return process(data)
}

// ❌ BAD: Manual cleanup in multiple places
func processFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return fmt.Errorf("open file: %w", err)
    }

    data, err := io.ReadAll(f)
    if err != nil {
        f.Close()  // Easy to forget
        return fmt.Errorf("read file: %w", err)
    }

    if err := process(data); err != nil {
        f.Close()  // Duplicated cleanup
        return err
    }

    f.Close()  // Have to remember to close in success path
    return nil
}
```

## Error Handling Best Practices Summary

1. **Always handle errors explicitly** - never use `_` to discard errors
2. **Wrap errors with context** - use `fmt.Errorf` with `%w`
3. **Use sentinel errors** - define package-level error variables
4. **Match errors correctly** - use `errors.Is` for sentinel errors, `errors.As` for types
5. **Single exit point in main()** - use the `run()` pattern
6. **Use defer for cleanup** - ensure resources are freed
7. **Don't panic in library code** - return errors instead
8. **Add context at each level** - error messages should trace the call stack
