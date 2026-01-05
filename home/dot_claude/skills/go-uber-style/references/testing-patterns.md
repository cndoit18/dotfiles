# Go Testing Patterns

Go emphasizes Test-Driven Development (TDD) with table-driven tests. This file covers comprehensive testing patterns.

## Test-Driven Development (TDD) Workflow

### Red-Green-Refactor Cycle

1. **Red**: Write a failing test
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve the code while keeping tests green

```go
// STEP 1 (RED): Write the failing test first
func TestUserValidation(t *testing.T) {
    user := &User{Email: "invalid-email"}
    err := user.Validate()
    if err == nil {
        t.Error("Expected validation error for invalid email")
    }
}

// STEP 2 (GREEN): Implement minimal code to pass
func (u *User) Validate() error {
    if !strings.Contains(u.Email, "@") {
        return ErrInvalidEmail
    }
    return nil
}

// STEP 3 (REFACTOR): Improve implementation
func (u *User) Validate() error {
    if u.Email == "" {
        return ErrEmailRequired
    }
    if !emailRegex.MatchString(u.Email) {
        return ErrInvalidEmail
    }
    return nil
}
```

## Table-Driven Tests

The idiomatic way to test multiple scenarios in Go:

```go
// ✅ GOOD: Comprehensive table-driven test
func TestParseURL(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *URL
        wantErr bool
    }{
        {
            name:  "valid_http_url",
            input: "http://example.com",
            want:  &URL{Scheme: "http", Host: "example.com"},
        },
        {
            name:  "valid_https_url",
            input: "https://example.com/path",
            want: &URL{
                Scheme: "https",
                Host:   "example.com",
                Path:   "/path",
            },
        },
        {
            name:    "invalid_url_missing_scheme",
            input:   "example.com",
            wantErr: true,
        },
        {
            name:    "empty_url",
            input:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseURL(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("ParseURL() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !tt.wantErr && !reflect.DeepEqual(got, tt.want) {
                t.Errorf("ParseURL() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

### Table-Driven Test Structure

```go
tests := []struct {
    name    string      // Descriptive test case name
    input   InputType   // Input to function
    want    OutputType  // Expected output
    wantErr bool        // Whether error is expected
}{
    // Test cases here
}

for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        // Test logic here
    })
}
```

## Testing Error Conditions

### Testing Sentinel Errors

```go
func TestGetUser_NotFound(t *testing.T) {
    repo := NewRepository(testDB)

    _, err := repo.GetUser("nonexistent-id")

    if !errors.Is(err, ErrUserNotFound) {
        t.Errorf("expected ErrUserNotFound, got %v", err)
    }
}
```

### Testing Custom Error Types

```go
func TestValidateUser_ValidationError(t *testing.T) {
    user := User{Email: "invalid"}

    err := user.Validate()

    var validationErr *ValidationError
    if !errors.As(err, &validationErr) {
        t.Fatalf("expected ValidationError, got %T", err)
    }

    if validationErr.Field != "email" {
        t.Errorf("expected Field = 'email', got %q", validationErr.Field)
    }
}
```

## Test Helpers

Use helper functions to reduce duplication:

```go
// ✅ GOOD: Test helper function
func assertEqual(t *testing.T, got, want interface{}) {
    t.Helper()  // Marks this as a helper function
    if !reflect.DeepEqual(got, want) {
        t.Errorf("\ngot:  %+v\nwant: %+v", got, want)
    }
}

func TestUserCreation(t *testing.T) {
    user := NewUser("John", "john@example.com")

    assertEqual(t, user.Name, "John")
    assertEqual(t, user.Email, "john@example.com")
}
```

## Testing with testify

Using the popular `testify` library for more expressive assertions:

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestUserValidation(t *testing.T) {
    user := &User{
        Name:  "John Doe",
        Email: "john@example.com",
        Age:   25,
    }

    err := user.Validate()

    // require stops test execution on failure
    require.NoError(t, err)

    // assert continues test execution on failure
    assert.Equal(t, "John Doe", user.Name)
    assert.Equal(t, "john@example.com", user.Email)
    assert.Greater(t, user.Age, 0)
}

func TestUserValidation_Invalid(t *testing.T) {
    user := &User{Email: "invalid"}

    err := user.Validate()

    require.Error(t, err)
    assert.Contains(t, err.Error(), "invalid email")
}
```

## Mocking and Interfaces

Design code with interfaces for testability:

```go
// Define interface for dependencies
type UserRepository interface {
    GetUser(id string) (*User, error)
    SaveUser(user *User) error
}

// Production implementation
type SQLRepository struct {
    db *sql.DB
}

func (r *SQLRepository) GetUser(id string) (*User, error) {
    // Database implementation
}

// Test implementation (mock)
type MockRepository struct {
    GetUserFunc func(id string) (*User, error)
    SaveUserFunc func(user *User) error
}

func (m *MockRepository) GetUser(id string) (*User, error) {
    if m.GetUserFunc != nil {
        return m.GetUserFunc(id)
    }
    return nil, errors.New("not implemented")
}

func (m *MockRepository) SaveUser(user *User) error {
    if m.SaveUserFunc != nil {
        return m.SaveUserFunc(user)
    }
    return errors.New("not implemented")
}

// Test using mock
func TestUserService_Activate(t *testing.T) {
    mockRepo := &MockRepository{
        GetUserFunc: func(id string) (*User, error) {
            return &User{ID: id, Active: false}, nil
        },
        SaveUserFunc: func(user *User) error {
            if !user.Active {
                t.Error("expected user to be activated")
            }
            return nil
        },
    }

    service := NewUserService(mockRepo)
    err := service.ActivateUser("user-123")

    require.NoError(t, err)
}
```

## Benchmarking

Use Go's built-in benchmarking:

```go
func BenchmarkProcessData(b *testing.B) {
    data := generateTestData(1000)

    b.ResetTimer()  // Reset timer after setup

    for i := 0; i < b.N; i++ {
        ProcessData(data)
    }
}

// With different input sizes
func BenchmarkProcessData_Sizes(b *testing.B) {
    sizes := []int{10, 100, 1000, 10000}

    for _, size := range sizes {
        b.Run(fmt.Sprintf("size-%d", size), func(b *testing.B) {
            data := generateTestData(size)
            b.ResetTimer()

            for i := 0; i < b.N; i++ {
                ProcessData(data)
            }
        })
    }
}
```

Run benchmarks:
```bash
go test -bench=. -benchmem
```

## Testing Concurrency

Use `-race` flag to detect race conditions:

```go
func TestCounter_Concurrent(t *testing.T) {
    counter := NewCounter()
    var wg sync.WaitGroup

    // Start 100 goroutines incrementing counter
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()

    if counter.Value() != 100 {
        t.Errorf("expected counter = 100, got %d", counter.Value())
    }
}
```

Run with race detector:
```bash
go test -race
```

## Test Coverage

Check test coverage:

```bash
# Run tests with coverage
go test -cover

# Generate coverage report
go test -coverprofile=coverage.out
go tool cover -html=coverage.out
```

Aim for 80-90% coverage on critical paths, but don't chase 100% blindly.

## Test Organization

### File Naming
- Test files: `filename_test.go`
- Same package: `package mypackage`
- Black-box tests: `package mypackage_test`

### Table-Driven Tests vs Individual Tests

```go
// ✅ GOOD: Use table-driven for multiple similar scenarios
func TestValidation(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        // Multiple test cases
    }
    // ...
}

// ✅ GOOD: Use individual tests for distinct scenarios
func TestUserCreation(t *testing.T) {
    // Test user creation
}

func TestUserDeletion(t *testing.T) {
    // Test user deletion
}
```

## Testing Best Practices

1. **Write tests first** (TDD) - tests guide design
2. **Use table-driven tests** - idiomatic and comprehensive
3. **Test behavior, not implementation** - tests should survive refactoring
4. **Use descriptive test names** - `TestFunctionName_Scenario_ExpectedBehavior`
5. **Keep tests independent** - tests should not depend on each other
6. **Use t.Helper()** - mark helper functions to get better error reporting
7. **Test edge cases** - empty inputs, nil values, boundary conditions
8. **Use -race flag** - detect concurrency issues
9. **Mock external dependencies** - use interfaces for testability
10. **Maintain tests** - update tests when requirements change

## Common Test Anti-Patterns

### Don't Test Implementation Details

```go
// ❌ BAD: Testing internal state
func TestUserService_Internal(t *testing.T) {
    service := NewUserService(mockRepo)
    service.process(user)

    if service.internalCache["key"] != "value" {
        t.Error("internal cache not set correctly")
    }
}

// ✅ GOOD: Test behavior
func TestUserService_GetUser(t *testing.T) {
    service := NewUserService(mockRepo)
    user, err := service.GetUser("user-123")

    require.NoError(t, err)
    assert.Equal(t, "user-123", user.ID)
}
```

### Don't Use Sleep for Synchronization

```go
// ❌ BAD: Using sleep
func TestAsync(t *testing.T) {
    go doSomething()
    time.Sleep(100 * time.Millisecond)  // Brittle and slow
    // assertions
}

// ✅ GOOD: Use synchronization primitives
func TestAsync(t *testing.T) {
    var wg sync.WaitGroup
    wg.Add(1)

    go func() {
        defer wg.Done()
        doSomething()
    }()

    wg.Wait()
    // assertions
}
```