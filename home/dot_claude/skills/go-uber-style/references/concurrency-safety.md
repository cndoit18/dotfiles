# Go Concurrency Safety Patterns

Go provides powerful concurrency primitives. This file covers safe concurrent programming patterns.

## Goroutines and Channels

### Channel Size: One or None (CRITICAL RULE)

**Uber Go Rule**: Channels should be unbuffered or have a buffer size of 1. Anything larger needs strong justification.

```go
// ✅ GOOD: Unbuffered channel
ch := make(chan int)

// ✅ GOOD: Buffer size of 1
ch := make(chan int, 1)

// ❌ BAD: Large buffer without justification
ch := make(chan int, 100)  // Why 100? This invites problems

// Why this matters:
// - Large buffers hide synchronization issues
// - Can cause deadlocks that are hard to debug
// - Resource waste if buffer is too large
// - Usually indicates a design problem
// - Unbuffered channels provide clear synchronization points

// Acceptable use of size 1:
// - Preventing goroutine blocking when exactly one result
// - Signal channels where blocking is not desired
results := make(chan Result, 1)
go func() {
    results <- computeResult()  // Won't block
}()
```

### Don't Fire-and-Forget Goroutines (CRITICAL RULE)

**Every goroutine must have a way to be stopped and waited on.**

```go
// ❌ BAD: Fire-and-forget goroutine
func process() {
    go func() {
        for {
            doWork()  // Runs forever, no way to stop!
        }
    }()
}

// ✅ GOOD: Goroutine with context cancellation
func process(ctx context.Context) {
    var wg sync.WaitGroup
    wg.Add(1)

    go func() {
        defer wg.Done()
        for {
            select {
            case <-ctx.Done():
                return  // Can be stopped
            default:
                doWork()
            }
        }
    }()

    wg.Wait()  // Can wait for completion
}

// ✅ GOOD: Goroutine with done channel
func process() (stop func()) {
    done := make(chan struct{})
    var wg sync.WaitGroup
    wg.Add(1)

    go func() {
        defer wg.Done()
        for {
            select {
            case <-done:
                return
            default:
                doWork()
            }
        }
    }()

    // Return function to stop and wait
    return func() {
        close(done)
        wg.Wait()
    }
}

// Why this matters:
// - Goroutine leaks waste memory and CPU
// - Leaked goroutines can hold onto resources
// - Makes graceful shutdown impossible
// - Testing becomes difficult
```

### No Goroutines in init() (CRITICAL RULE)

```go
// ❌ BAD: Starting goroutines in init()
func init() {
    go func() {
        // Background work
    }()
    // No way to control this goroutine's lifetime!
}

// ✅ GOOD: Start goroutines explicitly in constructors or Start methods
type Service struct {
    done chan struct{}
    wg   sync.WaitGroup
}

func NewService() *Service {
    return &Service{
        done: make(chan struct{}),
    }
}

func (s *Service) Start() {
    s.wg.Add(1)
    go func() {
        defer s.wg.Done()
        for {
            select {
            case <-s.done:
                return
            default:
                // Work
            }
        }
    }()
}

func (s *Service) Stop() {
    close(s.done)
    s.wg.Wait()
}

// Why this matters:
// - init() runs before main, no control over execution
// - No way to pass dependencies or configuration
// - Makes testing impossible
// - Can't stop goroutines started in init()
// - Leads to resource leaks
```

### Basic Goroutine Pattern

```go
// ✅ GOOD: Simple goroutine with WaitGroup
func processItems(items []Item) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        item := item  // Capture loop variable (Go < 1.22)

        go func() {
            defer wg.Done()
            process(item)
        }()
    }

    wg.Wait()
}

// ❌ BAD: Not capturing loop variable (Go < 1.22)
func processItems(items []Item) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func() {
            defer wg.Done()
            process(item)  // All goroutines see same variable!
        }()
    }

    wg.Wait()
}
```

Note: Go 1.22+ automatically captures loop variables, but maintain compatibility with older versions by explicitly capturing.

### Channel Communication

```go
// ✅ GOOD: Using channels for communication
func generator(max int) <-chan int {
    ch := make(chan int)

    go func() {
        defer close(ch)  // Always close channels
        for i := 0; i < max; i++ {
            ch <- i
        }
    }()

    return ch
}

func consumer() {
    for val := range generator(10) {
        fmt.Println(val)
    }
}
```

## Mutex for Shared State

### Proper Mutex Usage

```go
// ✅ GOOD: Mutex protects shared state
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}

// ❌ BAD: Exported mutex
type Counter struct {
    Mu    sync.Mutex  // Don't export mutexes
    Value int         // Don't export mutable state
}
```

### Copy Protection

Prevent copying structs with mutexes:

```go
// ✅ GOOD: Prevent copying
type Counter struct {
    mu    sync.Mutex
    value int
    _     noCopy  // or use sync.Mutex which has noCopy
}

// Compile-time copy check
type noCopy struct{}

func (*noCopy) Lock()   {}
func (*noCopy) Unlock() {}

// ❌ BAD: Allowing struct copy with mutex
func process(c Counter) {  // Copies mutex!
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

// ✅ GOOD: Pass by pointer
func process(c *Counter) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}
```

## Returning Defensive Copies

Prevent external mutation of internal state:

```go
// ✅ GOOD: Return defensive copy of map
type Stats struct {
    mu       sync.Mutex
    counters map[string]int
}

func (s *Stats) Snapshot() map[string]int {
    s.mu.Lock()
    defer s.mu.Unlock()

    // Create defensive copy
    result := make(map[string]int, len(s.counters))
    for k, v := range s.counters {
        result[k] = v
    }
    return result
}

// ❌ BAD: Returning reference to internal state
func (s *Stats) Snapshot() map[string]int {
    s.mu.Lock()
    defer s.mu.Unlock()
    return s.counters  // Caller can mutate internal state!
}
```

## Context for Cancellation

### Context-Aware Operations

```go
// ✅ GOOD: Respect context cancellation
func (w *Worker) processWork(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case work := <-w.workChan:
            if err := w.handleWork(ctx, work); err != nil {
                return fmt.Errorf("handle work: %w", err)
            }
        }
    }
}

// ✅ GOOD: Pass context to blocking operations
func fetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

### Context Best Practices

```go
// ✅ GOOD: Context as first parameter
func processData(ctx context.Context, data []byte) error {
    // Implementation
}

// ❌ BAD: Context not first parameter
func processData(data []byte, ctx context.Context) error {
    // Implementation
}

// ✅ GOOD: Don't store context in struct
type Worker struct {
    name string
}

func (w *Worker) Process(ctx context.Context) error {
    // Use context as parameter
}

// ❌ BAD: Storing context in struct
type Worker struct {
    ctx  context.Context  // Don't do this
    name string
}
```

## errgroup for Error Handling

Use `golang.org/x/sync/errgroup` for concurrent operations with error handling:

```go
import "golang.org/x/sync/errgroup"

// ✅ GOOD: Use errgroup for concurrent operations
func processFiles(ctx context.Context, files []string) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, file := range files {
        file := file  // Capture loop variable
        g.Go(func() error {
            return processFile(ctx, file)
        })
    }

    // Wait for all goroutines, returns first error
    if err := g.Wait(); err != nil {
        return fmt.Errorf("process files: %w", err)
    }
    return nil
}

// ✅ GOOD: Limit concurrency with semaphore
func processFilesLimited(ctx context.Context, files []string, maxConcurrent int) error {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(maxConcurrent)  // Limit concurrent goroutines

    for _, file := range files {
        file := file
        g.Go(func() error {
            return processFile(ctx, file)
        })
    }

    return g.Wait()
}
```

## sync.Once for Initialization

```go
// ✅ GOOD: Thread-safe lazy initialization
type Config struct {
    once   sync.Once
    data   *ConfigData
    initErr error
}

func (c *Config) Get() (*ConfigData, error) {
    c.once.Do(func() {
        c.data, c.initErr = loadConfig()
    })
    return c.data, c.initErr
}

// ❌ BAD: Not thread-safe
var config *ConfigData

func GetConfig() *ConfigData {
    if config == nil {  // Race condition!
        config = loadConfig()
    }
    return config
}
```

## Channel Patterns

### Worker Pool Pattern

```go
// ✅ GOOD: Worker pool with bounded concurrency
func workerPool(ctx context.Context, jobs <-chan Job, results chan<- Result, numWorkers int) {
    var wg sync.WaitGroup

    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                select {
                case <-ctx.Done():
                    return
                case results <- processJob(job):
                }
            }
        }()
    }

    wg.Wait()
    close(results)
}
```

### Fan-Out, Fan-In Pattern

```go
// ✅ GOOD: Fan-out, fan-in pattern
func fanOut(ctx context.Context, input <-chan int, numWorkers int) []<-chan int {
    outputs := make([]<-chan int, numWorkers)

    for i := 0; i < numWorkers; i++ {
        outputs[i] = worker(ctx, input)
    }

    return outputs
}

func worker(ctx context.Context, input <-chan int) <-chan int {
    output := make(chan int)

    go func() {
        defer close(output)
        for val := range input {
            select {
            case <-ctx.Done():
                return
            case output <- process(val):
            }
        }
    }()

    return output
}

func fanIn(ctx context.Context, channels ...<-chan int) <-chan int {
    output := make(chan int)
    var wg sync.WaitGroup

    for _, ch := range channels {
        wg.Add(1)
        ch := ch

        go func() {
            defer wg.Done()
            for val := range ch {
                select {
                case <-ctx.Done():
                    return
                case output <- val:
                }
            }
        }()
    }

    go func() {
        wg.Wait()
        close(output)
    }()

    return output
}
```

### Pipeline Pattern

```go
// ✅ GOOD: Pipeline pattern
func pipeline(ctx context.Context, input <-chan int) <-chan int {
    stage1 := stage1(ctx, input)
    stage2 := stage2(ctx, stage1)
    stage3 := stage3(ctx, stage2)
    return stage3
}

func stage1(ctx context.Context, input <-chan int) <-chan int {
    output := make(chan int)

    go func() {
        defer close(output)
        for val := range input {
            select {
            case <-ctx.Done():
                return
            case output <- val * 2:
            }
        }
    }()

    return output
}
```

## Race Condition Detection

### Common Race Conditions

```go
// ❌ BAD: Race condition on shared variable
type Counter struct {
    value int  // Not protected
}

func (c *Counter) Increment() {
    c.value++  // Race condition!
}

// ✅ GOOD: Protected with mutex
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

// ❌ BAD: Race on map
var cache = make(map[string]string)

func get(key string) string {
    return cache[key]  // Race!
}

func set(key, value string) {
    cache[key] = value  // Race!
}

// ✅ GOOD: Use sync.Map for concurrent access
var cache sync.Map

func get(key string) (string, bool) {
    val, ok := cache.Load(key)
    if !ok {
        return "", false
    }
    return val.(string), true
}

func set(key, value string) {
    cache.Store(key, value)
}
```

## Testing Concurrent Code

### Use -race Flag

```bash
go test -race
```

```go
// Test that triggers race detector
func TestCounter_Concurrent(t *testing.T) {
    counter := NewCounter()
    var wg sync.WaitGroup

    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()

    if counter.Value() != 100 {
        t.Errorf("expected 100, got %d", counter.Value())
    }
}
```

## Concurrency Best Practices

1. **Use channels for communication** - Share memory by communicating
2. **Use mutexes for state** - Protect shared mutable state
3. **Don't communicate by sharing memory** - Share memory by communicating
4. **Always close channels** - Close from sender, not receiver
5. **Use context for cancellation** - Pass context as first parameter
6. **Use errgroup** - For concurrent operations with error handling
7. **Capture loop variables** - When starting goroutines in loops
8. **Return defensive copies** - Don't expose internal mutable state
9. **Test with -race** - Detect race conditions early
10. **Use sync.Once for initialization** - Thread-safe lazy initialization

## Common Concurrency Anti-Patterns

### Forgetting to Close Channels

```go
// ❌ BAD: Channel never closed, goroutine leaks
func generator() <-chan int {
    ch := make(chan int)
    go func() {
        for i := 0; i < 10; i++ {
            ch <- i
        }
        // Never closes ch!
    }()
    return ch
}

// ✅ GOOD: Always close channels
func generator() <-chan int {
    ch := make(chan int)
    go func() {
        defer close(ch)
        for i := 0; i < 10; i++ {
            ch <- i
        }
    }()
    return ch
}
```

### Starting Goroutines Without Cleanup

```go
// ❌ BAD: No way to stop goroutine
func start() {
    go func() {
        for {
            doWork()  // Runs forever!
        }
    }()
}

// ✅ GOOD: Use context for cancellation
func start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return
            default:
                doWork()
            }
        }
    }()
}
```
