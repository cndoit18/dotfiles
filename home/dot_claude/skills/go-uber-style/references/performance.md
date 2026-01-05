# Go Performance Patterns

Performance optimizations following the Uber Go Style Guide.

## String Conversions

### Prefer strconv over fmt

For converting primitives to/from strings, use `strconv` instead of `fmt`.

```go
// ❌ BAD: Using fmt for primitive conversions
s := fmt.Sprintf("%d", n)
n, err := fmt.Sscanf(s, "%d", &val)

// ✅ GOOD: Use strconv for primitives
s := strconv.Itoa(n)
n, err := strconv.Atoi(s)

// ✅ GOOD: strconv for other types
s := strconv.FormatInt(n, 10)
s := strconv.FormatFloat(f, 'f', -1, 64)
s := strconv.FormatBool(b)

n, err := strconv.ParseInt(s, 10, 64)
f, err := strconv.ParseFloat(s, 64)
b, err := strconv.ParseBool(s)

// Why this matters:
// - strconv is significantly faster than fmt
// - Fewer allocations
// - More explicit about what's being converted
```

**Benchmark comparison:**

```go
// BenchmarkFmtSprint-8    10000000    143 ns/op    2 allocs/op
// BenchmarkStrconv-8      20000000     64 ns/op    1 allocs/op
```

### Avoid Repeated String-to-Byte Conversions

Don't convert the same string to `[]byte` repeatedly, especially in loops.

```go
// ❌ BAD: Converting in every iteration
func processRecords(w io.Writer, records []string) {
    for _, record := range records {
        w.Write([]byte(record))  // Allocation on every iteration!
    }
}

// ✅ GOOD: Convert once, reuse when possible
func processRecords(w io.Writer, records []string) {
    for _, record := range records {
        // If record content changes, must convert each time
        w.Write([]byte(record))
    }
}

// ✅ BEST: For static strings, convert once
const greeting = "Hello, World!"
var greetingBytes = []byte(greeting)  // Converted once at package init

func writeGreeting(w io.Writer) error {
    _, err := w.Write(greetingBytes)  // No allocation
    return err
}

// ❌ BAD: Static string conversion in loop
func writeGreetings(w io.Writer, count int) {
    for i := 0; i < count; i++ {
        w.Write([]byte("Hello"))  // Allocates every time!
    }
}

// ✅ GOOD: Convert once
func writeGreetings(w io.Writer, count int) {
    hello := []byte("Hello")
    for i := 0; i < count; i++ {
        w.Write(hello)  // No allocation in loop
    }
}

// Why this matters:
// - String to []byte conversion allocates memory
// - In hot paths or loops, this adds up quickly
// - Easy performance win with minimal code change
```

## Container Capacity

### Pre-allocate Slices with Known Capacity

When you know the size of a slice ahead of time, always specify the capacity.

```go
// ❌ BAD: No capacity hint
func processItems(items []Item) []Result {
    var results []Result  // Will grow and reallocate multiple times
    for _, item := range items {
        results = append(results, process(item))
    }
    return results
}

// ✅ GOOD: Pre-allocate with known capacity
func processItems(items []Item) []Result {
    results := make([]Result, 0, len(items))  // Single allocation
    for _, item := range items {
        results = append(results, process(item))
    }
    return results
}

// ✅ GOOD: When final size is known, allocate directly
func processItems(items []Item) []Result {
    results := make([]Result, len(items))  // Allocate exact size
    for i, item := range items {
        results[i] = process(item)
    }
    return results
}

// Why this matters:
// - Slices grow by doubling when capacity is exceeded
// - Multiple reallocations mean multiple copies
// - Pre-allocation avoids this overhead
```

**Benchmark comparison:**

```go
// BenchmarkNoCapacity-8      1000000    1299 ns/op    2048 B/op    6 allocs/op
// BenchmarkWithCapacity-8    2000000     720 ns/op     896 B/op    1 allocs/op
```

### Pre-allocate Maps with Known Capacity

Similarly, provide capacity hints when creating maps.

```go
// ❌ BAD: No capacity hint
func createIndex(files []File) map[string]File {
    index := make(map[string]File)  // Will grow and rehash multiple times
    for _, file := range files {
        index[file.Name] = file
    }
    return index
}

// ✅ GOOD: Capacity hint provided
func createIndex(files []File) map[string]File {
    index := make(map[string]File, len(files))  // Single allocation
    for _, file := range files {
        index[file.Name] = file
    }
    return index
}

// Why this matters:
// - Maps must rehash and reallocate when growing
// - Providing capacity prevents this overhead
// - Especially important for large maps
```

## General Performance Principles

### Reduce Variable Scope

Keep variables as close to their use as possible. Smaller scope means less memory pressure.

```go
// ❌ BAD: Variable lives longer than needed
func process(items []Item) error {
    var result Result  // Allocated for entire function

    for _, item := range items {
        if item.NeedsProcessing() {
            result = computeResult(item)
            if err := save(result); err != nil {
                return err
            }
        }
    }
    return nil
}

// ✅ GOOD: Minimal scope
func process(items []Item) error {
    for _, item := range items {
        if !item.NeedsProcessing() {
            continue
        }
        result := computeResult(item)  // Only allocated when needed
        if err := save(result); err != nil {
            return err
        }
    }
    return nil
}
```

### Avoid Unnecessary Allocations in Loops

```go
// ❌ BAD: Allocating inside loop
func process(items []Item) {
    for _, item := range items {
        buffer := make([]byte, 1024)  // Allocates every iteration!
        processWithBuffer(item, buffer)
    }
}

// ✅ GOOD: Allocate once, reuse
func process(items []Item) {
    buffer := make([]byte, 1024)  // Single allocation
    for _, item := range items {
        processWithBuffer(item, buffer)
    }
}

// ✅ GOOD: Use sync.Pool for frequently allocated objects
var bufferPool = sync.Pool{
    New: func() interface{} {
        return make([]byte, 1024)
    },
}

func process(items []Item) {
    buffer := bufferPool.Get().([]byte)
    defer bufferPool.Put(buffer)

    for _, item := range items {
        processWithBuffer(item, buffer)
    }
}
```

### Use Pointer vs Value Receivers Appropriately

```go
// Prefer value receivers for small, immutable types
type Point struct {
    X, Y int
}

func (p Point) String() string {  // Value receiver - Point is small
    return fmt.Sprintf("(%d, %d)", p.X, p.Y)
}

// Use pointer receivers for large types to avoid copying
type LargeStruct struct {
    Data [10000]int
}

func (l *LargeStruct) Process() {  // Pointer receiver - avoid copying
    // Process data
}

// Use pointer receivers for methods that mutate
type Counter struct {
    count int
}

func (c *Counter) Increment() {  // Pointer receiver - mutates
    c.count++
}
```

## Performance Testing

### Use Benchmarks

```go
func BenchmarkProcessItems(b *testing.B) {
    items := generateTestItems(1000)

    b.ResetTimer()  // Don't include setup time

    for i := 0; i < b.N; i++ {
        processItems(items)
    }
}

// Run benchmarks with memory statistics
// go test -bench=. -benchmem
```

### Profile Before Optimizing

```go
import _ "net/http/pprof"

// Enable profiling in main
go func() {
    log.Println(http.ListenAndServe("localhost:6060", nil))
}()

// Then access:
// http://localhost:6060/debug/pprof/
```

## Performance Best Practices Summary

1. **Use strconv, not fmt** for primitive string conversions
2. **Avoid repeated string-to-byte** conversions
3. **Pre-allocate slices and maps** when size is known
4. **Reduce variable scope** to minimize memory pressure
5. **Reuse buffers** instead of allocating in loops
6. **Use pointer receivers** for large structs or mutations
7. **Benchmark and profile** before optimizing
8. **Don't optimize prematurely** - measure first

## When to Optimize

```go
// Quote from Donald Knuth:
// "Premature optimization is the root of all evil"

// Optimization checklist:
// 1. Does this code have a performance problem? (Measure!)
// 2. Is this code in a hot path? (Profile!)
// 3. Will optimization make code significantly less readable?
// 4. Can I write a benchmark to verify improvement?

// Only optimize when you can answer:
// - YES to 1 and 2
// - NO to 3
// - YES to 4
```