# Uber Go Style Guide Patterns

This file contains comprehensive patterns and anti-patterns from the Uber Go Style Guide.

## File Organization

Follow this order in Go files:

```go
package user

// 1. Import statements (grouped by standard library, third-party, local)
import (
    "errors"  // Standard library first
    "fmt"
    "time"

    "github.com/pkg/errors"  // Third-party

    "myproject/internal/db"  // Local packages
)

// 2. Types first
type User struct {
    ID        string
    Name      string
    Email     string
    CreatedAt time.Time
}

// 3. Constructors (New* functions)
func NewUser(name, email string) *User {
    return &User{
        ID:        generateID(),
        Name:      name,
        Email:     email,
        CreatedAt: time.Now(),
    }
}

// 4. Methods grouped by receiver
func (u *User) Validate() error {
    if u.Email == "" {
        return ErrInvalidEmail
    }
    return nil
}

// 5. Plain utility functions last
func generateID() string {
    return fmt.Sprintf("user_%d", time.Now().Unix())
}
```

## Interface Design

### Pointers to Interfaces (NEVER USE)

```go
// ❌ BAD: Never use pointer to interface
func Process(r *io.Reader) error {
    // This is almost never what you want
    // Interfaces already contain a pointer internally
}

// ✅ GOOD: Interfaces are already reference types
func Process(r io.Reader) error {
    data, err := io.ReadAll(r)
    if err != nil {
        return err
    }
    return process(data)
}

// Why this matters:
// - Interfaces in Go are already reference-like (they hold a value and type)
// - Pointer-to-interface adds unnecessary indirection
// - It's almost never the correct solution
// - Causes confusion about nil semantics
```

### Receivers and Interfaces

Choose receiver type (value vs pointer) consistently:

```go
// ✅ GOOD: Use pointer receivers for mutations
type Counter struct {
    count int
}

func (c *Counter) Increment() {
    c.count++  // Mutates, needs pointer
}

func (c *Counter) Value() int {
    return c.count  // Could be value, but stay consistent
}

// ❌ BAD: Inconsistent receivers
type Counter struct {
    count int
}

func (c *Counter) Increment() {  // Pointer
    c.count++
}

func (c Counter) Value() int {  // Value - inconsistent!
    return c.count
}

// Rules for choosing receivers:
// 1. If method mutates receiver → pointer
// 2. If receiver is large struct → pointer (avoid copying)
// 3. If any method needs pointer → all methods use pointer (consistency)
// 4. If receiver is map, slice, chan → value (already references)
// 5. If receiver is small, immutable → value is OK
```

### Small, Focused Interfaces

```go
// ✅ GOOD: Small, focused interfaces
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}

// ✅ GOOD: Compose when needed
type ReadWriter interface {
    Reader
    Writer
}

// ✅ GOOD: Verify interface compliance at compile time
var _ http.Handler = (*MyHandler)(nil)
```

### Accept Interfaces, Return Concrete Types

```go
// ✅ GOOD: Accept interfaces for flexibility
func ProcessData(r io.Reader) (*Result, error) {
    data, err := io.ReadAll(r)
    if err != nil {
        return nil, err
    }
    return &Result{Data: data}, nil
}

// ❌ BAD: Don't return interfaces unless necessary
func GetReader() io.Reader {
    return &MyReader{}
}

// ✅ GOOD: Return concrete types
func GetReader() *MyReader {
    return &MyReader{}
}
```

## Zero Values and Initialization

### Leverage Zero Values

```go
// ✅ GOOD: Zero values are ready to use
var mu sync.Mutex  // Ready to use immediately
mu.Lock()
defer mu.Unlock()

// ✅ GOOD: Nil slices work for most operations
var users []User  // nil slice, perfectly valid
users = append(users, User{})
```

### Use nil for Empty Slices

```go
// ✅ GOOD: Return nil for empty results
func findActiveUsers(users []User) []User {
    var active []User  // nil slice, perfectly valid
    for _, user := range users {
        if user.IsActive() {
            active = append(active, user)
        }
    }
    return active  // Returns nil if no active users
}

// ❌ BAD: Don't allocate empty slices unnecessarily
func findActiveUsers(users []User) []User {
    active := []User{}  // Allocates empty slice
    // ...
    return active
}
```

## Performance Patterns

### Pre-allocate with Known Capacity

```go
// ✅ GOOD: Pre-allocate with known capacity
func processItems(items []string) []ProcessedItem {
    result := make([]ProcessedItem, 0, len(items))
    for _, item := range items {
        result = append(result, ProcessItem(item))
    }
    return result
}

// ❌ BAD: No pre-allocation
func processItems(items []string) []ProcessedItem {
    var result []ProcessedItem  // Will grow repeatedly
    for _, item := range items {
        result = append(result, ProcessItem(item))
    }
    return result
}
```

### Reduce Variable Scope

```go
// ✅ GOOD: Minimize variable scope
if err := os.WriteFile(name, data, 0644); err != nil {
    return err
}

// ❌ BAD: Unnecessary variable scope
err := os.WriteFile(name, data, 0644)
if err != nil {
    return err
}
// err is still in scope here unnecessarily
```

## Safe Type Assertions

```go
// ✅ GOOD: Always use two-value form
func processValue(i interface{}) error {
    s, ok := i.(string)
    if !ok {
        return errors.New("expected string type")
    }
    return process(s)
}

// ❌ BAD: Single-value form panics on failure
func processValue(i interface{}) error {
    s := i.(string)  // Panics if i is not a string
    return process(s)
}
```

## Functional Options Pattern

Use functional options when you need more than 4 parameters:

```go
// ✅ GOOD: Functional options for many parameters
type Option interface {
    apply(*config)
}

type cacheOption bool

func (c cacheOption) apply(cfg *config) {
    cfg.cacheEnabled = bool(c)
}

func WithCache(enabled bool) Option {
    return cacheOption(enabled)
}

type timeoutOption time.Duration

func (t timeoutOption) apply(cfg *config) {
    cfg.timeout = time.Duration(t)
}

func WithTimeout(d time.Duration) Option {
    return timeoutOption(d)
}

type config struct {
    cacheEnabled bool
    timeout      time.Duration
}

var defaultConfig = config{
    cacheEnabled: true,
    timeout:      30 * time.Second,
}

func Open(addr string, opts ...Option) (*Connection, error) {
    cfg := defaultConfig
    for _, opt := range opts {
        opt.apply(&cfg)
    }
    return connect(addr, cfg)
}

// Usage:
conn, err := Open("localhost:8080",
    WithCache(false),
    WithTimeout(60*time.Second),
)
```

## Structural Limits

- **Functions**: ≤50 lines maximum
- **Structs**: ≤200 lines maximum
- **Parameters**: ≤4 parameters per function
- Break limits only with clear documentation and approval

```go
// ✅ GOOD: Under 50 lines, focused responsibility
func processUser(ctx context.Context, userID string) error {
    user, err := fetchUser(ctx, userID)
    if err != nil {
        return fmt.Errorf("fetch user %q: %w", userID, err)
    }

    if err := validateUser(user); err != nil {
        return fmt.Errorf("validate user %q: %w", userID, err)
    }

    return updateUserStatus(ctx, user)
}

// ❌ BAD: Too many parameters
func CreateUser(name, email, phone, address, city, state, zip string) error {
    // 7 parameters is too many
}

// ✅ GOOD: Use a struct for many related parameters
type UserInfo struct {
    Name    string
    Email   string
    Phone   string
    Address string
    City    string
    State   string
    Zip     string
}

func CreateUser(info UserInfo) error {
    // Much better
}
```

## Common Anti-Patterns

### God Structs

```go
// ❌ BAD: Struct doing too much
type UserManager struct {
    db            *sql.DB
    cache         *redis.Client
    emailSender   *EmailClient
    smsService    *SMSClient
    paymentGateway *PaymentClient
    // ... too many responsibilities
}

// ✅ GOOD: Separate concerns
type UserRepository struct {
    db *sql.DB
}

type UserNotifier struct {
    emailSender *EmailClient
}

type UserService struct {
    repo     *UserRepository
    notifier *UserNotifier
}
```

### Ignoring Errors

```go
// ❌ BAD: Ignoring errors
func processFile(path string) {
    data, _ := os.ReadFile(path)  // Ignoring error!
    process(data)
}

// ✅ GOOD: Handle all errors
func processFile(path string) error {
    data, err := os.ReadFile(path)
    if err != nil {
        return fmt.Errorf("read file %q: %w", path, err)
    }
    return process(data)
}
```

### Panic in Library Code

```go
// ❌ BAD: Panic in library/package code
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
```

### Avoid Embedding Types in Public Structs

```go
// ❌ BAD: Embedding in public struct exposes unwanted methods
type Server struct {
    http.Server  // Exposes ALL http.Server methods!
    config Config
}

// Now Server has 20+ methods from http.Server that may not be intended

// ✅ GOOD: Use composition, embed only when method promotion is explicitly desired
type Server struct {
    server *http.Server  // Encapsulated, controlled API
    config Config
}

func (s *Server) Start() error {
    return s.server.ListenAndServe()
}

// ❌ VERY BAD: Embedding mutex in public struct
type SMap struct {
    sync.Mutex  // Exposes Lock/Unlock publicly!
    data map[string]string
}

// ✅ GOOD: Mutex as private field
type SMap struct {
    mu   sync.Mutex
    data map[string]string
}

// Why this matters:
// - Embedded types expose ALL their methods
// - Makes API evolution impossible (can't change internal implementation)
// - Breaks encapsulation
// - Especially dangerous with mutexes (exposes Lock/Unlock)
```

### Avoid Using Built-In Names

```go
// ❌ BAD: Shadowing built-in names
func process() {
    var error string  // Shadows built-in error type!
    var string int    // Shadows built-in string type!
}

type User struct {
    error string  // Don't use built-in names as fields!
}

// ✅ GOOD: Use descriptive names
func process() {
    var errMsg string
    var name string
}

type User struct {
    errorMessage string
}

// Common built-ins to avoid:
// - error, string, int, bool, byte, rune
// - true, false, nil
// - make, len, cap, new, append, copy, delete
// - close, panic, recover
```

### Avoid Mutable Globals

```go
// ❌ BAD: Mutable global state
var cache = map[string]string{}

func Get(key string) string {
    return cache[key]  // Hides dependency, breaks test isolation
}

func Set(key, value string) {
    cache[key] = value  // Mutation in global scope
}

// ✅ GOOD: Dependency injection
type Cache struct {
    data map[string]string
}

func NewCache() *Cache {
    return &Cache{
        data: make(map[string]string),
    }
}

func (c *Cache) Get(key string) string {
    return c.data[key]
}

func (c *Cache) Set(key, value string) {
    c.data[key] = value
}

// Why this matters:
// - Mutable globals hide dependencies
// - Break test isolation (tests can't run in parallel)
// - Make code harder to reason about
// - Prevent proper initialization control
```

### Avoid init()

```go
// ❌ BAD: Using init() for side effects
var db *sql.DB

func init() {
    var err error
    db, err = sql.Open("postgres", "connection-string")
    if err != nil {
        log.Fatal(err)  // Can't test this!
    }
}

// ✅ GOOD: Explicit initialization
type App struct {
    db *sql.DB
}

func NewApp(connStr string) (*App, error) {
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        return nil, fmt.Errorf("open database: %w", err)
    }
    return &App{db: db}, nil
}

// init() is acceptable ONLY for:
// - Truly static initialization
// - Registering with registries (e.g., database drivers)
// - Computing one-time values

// ❌ NEVER in init():
// - I/O operations
// - Network calls
// - Global state mutations
// - Goroutines (especially!)
```

### Use Field Tags in Marshaled Structs

```go
// ❌ BAD: No field tags - breaks on refactoring
type User struct {
    Name  string
    Email string
}

// If you rename Name → FullName, JSON changes!

// ✅ GOOD: Explicit field tags
type User struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}

// Now you can refactor safely:
type User struct {
    FullName string `json:"name"`      // JSON stays "name"
    Email    string `json:"email"`
}

// ✅ GOOD: Use tags for all marshaling formats
type User struct {
    Name  string `json:"name" yaml:"name" xml:"name"`
    Email string `json:"email" yaml:"email" xml:"email"`
}

// Why this matters:
// - Enables safe refactoring
// - Maintains API backwards compatibility
// - Makes serialization format explicit
// - Prevents accidental breaking changes
```

## Time and Enums

### Use time.Time for Instants, time.Duration for Periods

```go
// ❌ BAD: Using int64 for time
type Config struct {
    Timeout  int64  // Seconds? Milliseconds? Unclear!
    Created  int64  // Unix timestamp? Unclear!
}

// ✅ GOOD: Use proper time types
type Config struct {
    Timeout time.Duration  // Clear: duration
    Created time.Time      // Clear: point in time
}

// ✅ GOOD: Using time types prevents errors
func process(timeout time.Duration) {
    ctx, cancel := context.WithTimeout(context.Background(), timeout)
    defer cancel()
    // No confusion about units!
}

// ❌ BAD: External systems with int (without units in name)
type APIConfig struct {
    Timeout int `json:"timeout"`  // What unit?
}

// ✅ GOOD: External systems with explicit units
type APIConfig struct {
    TimeoutMillis int `json:"timeout_millis"`  // Clear!
}

func (c *APIConfig) GetTimeout() time.Duration {
    return time.Duration(c.TimeoutMillis) * time.Millisecond
}
```

### Start Enums at One

```go
// ❌ BAD: Starting enum at zero
type Status int

const (
    StatusPending Status = iota  // 0 - indistinguishable from zero value!
    StatusRunning                // 1
    StatusComplete               // 2
)

// Problem: Uninitialized Status is StatusPending!
var s Status  // s == StatusPending, but it's uninitialized

// ✅ GOOD: Start at one (unless zero is meaningful)
type Status int

const (
    StatusUnknown Status = iota  // 0 - explicit unknown state
    StatusPending                // 1
    StatusRunning                // 2
    StatusComplete               // 3
)

// ✅ BETTER: Start at one if zero isn't meaningful
type Status int

const (
    _ Status = iota  // Skip zero
    StatusPending    // 1
    StatusRunning    // 2
    StatusComplete   // 3
)

// Why this matters:
// - Zero values in Go are uninitialized
// - Starting at 1 makes uninitialized values detectable
// - Prevents bugs from forgetting to set enum values
```

## Atomic Operations

### Use go.uber.org/atomic

```go
// ❌ BAD: Using sync/atomic primitives directly
type Counter struct {
    count int64
}

func (c *Counter) Inc() {
    atomic.AddInt64(&c.count, 1)  // Easy to get wrong
}

func (c *Counter) Value() int64 {
    return atomic.LoadInt64(&c.count)  // Verbose
}

// ✅ GOOD: Use go.uber.org/atomic
import "go.uber.org/atomic"

type Counter struct {
    count atomic.Int64
}

func (c *Counter) Inc() {
    c.count.Add(1)  // Type-safe, cleaner
}

func (c *Counter) Value() int64 {
    return c.count.Load()  // Clearer intent
}

// Why this matters:
// - Type safety (can't accidentally use non-atomic operations)
// - Clearer code
// - Less error-prone than sync/atomic primitives
// - Better API for common patterns
```