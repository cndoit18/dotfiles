package example

import "time"

// Functional Options Pattern
// Use this pattern when you need more than 4 parameters
// This provides a clean, extensible API

// Option is a functional option for configuring the service
type Option interface {
	apply(*config)
}

// config holds the configuration
type config struct {
	timeout      time.Duration
	retries      int
	cacheEnabled bool
	logLevel     string
}

// Default configuration
var defaultConfig = config{
	timeout:      30 * time.Second,
	retries:      3,
	cacheEnabled: true,
	logLevel:     "info",
}

// Option implementations

type timeoutOption time.Duration

func (t timeoutOption) apply(cfg *config) {
	cfg.timeout = time.Duration(t)
}

// WithTimeout sets the timeout duration
func WithTimeout(d time.Duration) Option {
	return timeoutOption(d)
}

type retriesOption int

func (r retriesOption) apply(cfg *config) {
	cfg.retries = int(r)
}

// WithRetries sets the number of retries
func WithRetries(n int) Option {
	return retriesOption(n)
}

type cacheOption bool

func (c cacheOption) apply(cfg *config) {
	cfg.cacheEnabled = bool(c)
}

// WithCache enables or disables caching
func WithCache(enabled bool) Option {
	return cacheOption(enabled)
}

type logLevelOption string

func (l logLevelOption) apply(cfg *config) {
	cfg.logLevel = string(l)
}

// WithLogLevel sets the logging level
func WithLogLevel(level string) Option {
	return logLevelOption(level)
}

// Service is the main service struct
type Service struct {
	cfg config
}

// NewService creates a new service with functional options
func NewService(addr string, opts ...Option) *Service {
	// Start with default config
	cfg := defaultConfig

	// Apply all options
	for _, opt := range opts {
		opt.apply(&cfg)
	}

	return &Service{
		cfg: cfg,
	}
}

// Usage example:
/*
service := NewService("localhost:8080",
	WithTimeout(60*time.Second),
	WithRetries(5),
	WithCache(false),
	WithLogLevel("debug"),
)
*/

// Alternative pattern using function closures
// This is more concise but less type-safe

type OptionFunc func(*config)

func (f OptionFunc) apply(cfg *config) {
	f(cfg)
}

func WithTimeoutFunc(d time.Duration) OptionFunc {
	return func(cfg *config) {
		cfg.timeout = d
	}
}

func WithRetriesFunc(n int) OptionFunc {
	return func(cfg *config) {
		cfg.retries = n
	}
}

// Both patterns work the same way at the call site
