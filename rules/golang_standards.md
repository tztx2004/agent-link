# Go Engineering Standards & Patterns

Rules and quality standards enforced across all Go implementation, refactoring, and review work.
These rules integrate the three core Go skills: `golang-patterns`, `golang-pro`, and `golang-testing`.

---

## 0. Mandatory Go Quality Skills

Whenever a task touches, creates, or reviews Go code (`*.go`), apply the following three skill lenses:

| Skill | Primary Focus & Verification |
| :--- | :--- |
| **`golang-patterns`** | Idiomatic Go, error wrapping (`%w`), consumer-defined interfaces, context propagation, no naked returns |
| **`golang-pro`** | Safe concurrency, leak-free goroutines, channel ownership, `errgroup`/`sync`, graceful shutdown |
| **`golang-testing`** | Table-driven tests, subtests (`t.Run`), deterministic cleanups (`t.Cleanup`), race detector (`-race`) |

---

## 1. Idiomatic Go & Error Handling (`golang-patterns`)

### ✅ Error Wrapping & Context
- **Never ignore errors**: Explicitly handle every error. Never assign `_ = err` or ignore returned errors from I/O or database operations.
- **Wrap errors with context**: Use `fmt.Errorf("action description: %w", err)` to preserve the causal chain for `errors.Is` and `errors.As`.
- **Sentinel Errors vs Custom Types**:
  - Export sentinel errors with `ErrXxx = errors.New(...)` for package-level predictable failures.
  - Use custom error structs when callers need to extract structured details (e.g. HTTP status, retry duration).

### ✅ Context Propagation
- Any function performing I/O, network calls, DB queries, or long-running work **MUST accept `ctx context.Context` as its first parameter**.
- Always check `ctx.Err()` or `<-ctx.Done()` before and during blocking iterations.
- Never store a `context.Context` inside a struct; pass it explicitly down the call stack.

### ✅ Interface Design
- **Consumer-side interfaces**: Define interfaces where they are *used* (consumer package), not where they are implemented.
- **Keep interfaces small**: Strive for 1–2 methods (e.g., `io.Reader`, `io.Closer`). Small interfaces are easily mocked and highly composable.
- Avoid returning interfaces from constructors; return concrete structs and accept interfaces.

---

## 2. Concurrency & Goroutine Safety (`golang-pro`)

### ❌ Zero Goroutine Leaks
- Every goroutine spawned **MUST have a guaranteed, deterministic exit path**.
- An unbuffered channel write or read without a `case <-ctx.Done():` fallback will leak if the consumer abandons the operation:

```go
// ❌ Dangerous: leaks if receiver drops early
go func() {
    ch <- result
}()

// ✅ Safe: honors cancellation
go func() {
    select {
    case ch <- result:
    case <-ctx.Done():
    }
}()
```

### ✅ Lifecycle Coordination
- Use `errgroup.WithContext(ctx)` for concurrent tasks that should fail fast on the first error.
- Use `sync.WaitGroup` with `defer wg.Done()` for fan-out tasks where all results must complete regardless of errors.
- **Channel ownership rule**: Only the sender (the goroutine that creates and writes to the channel) may close it. Receivers must never close channels.

### ✅ Mutex & Shared State
- Keep critical sections minimal. Never perform network I/O or blocking operations while holding a `sync.Mutex` or `sync.RWMutex`.
- Prefer communication over sharing memory: use channels for passing ownership, mutexes for synchronizing internal struct state.

---

## 3. Testing & Verification Standards (`golang-testing`)

### ✅ Table-Driven Unit Tests
All new or modified functions with business logic, validation, or state changes must include table-driven tests:

```go
func TestCalculateDiscount(t *testing.T) {
    tests := []struct {
        name    string
        input   int
        want    int
        wantErr bool
    }{
        {name: "standard customer", input: 100, want: 90, wantErr: false},
        {name: "invalid negative amount", input: -1, want: 0, wantErr: true},
    }

    for _, tc := range tests {
        tc := tc // capture range variable for Go < 1.22
        t.Run(tc.name, func(t *testing.T) {
            got, err := CalculateDiscount(tc.input)
            if (err != nil) != tc.wantErr {
                t.Fatalf("CalculateDiscount() error = %v, wantErr %v", err, tc.wantErr)
            }
            if got != tc.want {
                t.Errorf("CalculateDiscount() = %v, want %v", got, tc.want)
            }
        })
    }
}
```

### ✅ Test Cleanups & Race Detection
- Use `t.Cleanup(func() { ... })` instead of `defer` inside subtests to ensure resource release occurs in the subtest's own lifecycle.
- Always execute tests with the race detector enabled: `go test -v -race ./...`.

---

## 4. Verification Gate Integration

When completing any Go implementation or review, check the following before writing the Verification section:

### Gate B — Rule Conformance (Go Standards)
- [ ] Error wrapping: errors wrapped with `%w` and descriptive prefix.
- [ ] Context propagation: I/O/DB methods accept `ctx context.Context` as first parameter.
- [ ] Goroutine lifecycle: no spawned goroutine without a `ctx.Done()` exit path or `errgroup` coordination.
- [ ] Consumer interfaces: interfaces defined by the caller, concrete types returned by constructors.

### Gate C — Evidence (Command Outputs)
Run and capture actual terminal outputs:
```bash
# 1. Type and syntax sanity check
go vet ./...

# 2. Test suite with race detector
go test -v -race ./...

# 3. Linter check (if configured in repository)
golangci-lint run
```
Report the exact command and terminal output in the final evidence block.
