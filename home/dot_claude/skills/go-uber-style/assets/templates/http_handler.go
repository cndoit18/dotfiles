package example

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
)

// HTTP Handler Template with Proper Error Handling

// Request/Response types
type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type CreateUserResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}

// Sentinel errors
var (
	ErrInvalidInput = errors.New("invalid input")
	ErrUserExists   = errors.New("user already exists")
)

// UserService defines the interface for user operations
type UserService interface {
	CreateUser(name, email string) (*User, error)
}

// User represents a user
type User struct {
	ID    string
	Name  string
	Email string
}

// Handler holds dependencies
type Handler struct {
	service UserService
	logger  *log.Logger
}

// NewHandler creates a new handler
func NewHandler(service UserService, logger *log.Logger) *Handler {
	return &Handler{
		service: service,
		logger:  logger,
	}
}

// CreateUserHandler handles user creation requests
// This pattern separates HTTP concerns from business logic
func (h *Handler) CreateUserHandler(w http.ResponseWriter, r *http.Request) {
	// Only accept POST requests
	if r.Method != http.MethodPost {
		h.respondError(w, http.StatusMethodNotAllowed, "method not allowed", nil)
		return
	}

	// Parse request
	var req CreateUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.respondError(w, http.StatusBadRequest, "invalid request body", err)
		return
	}

	// Validate input
	if err := validateCreateUserRequest(req); err != nil {
		h.respondError(w, http.StatusBadRequest, "validation failed", err)
		return
	}

	// Call service
	user, err := h.service.CreateUser(req.Name, req.Email)
	if err != nil {
		// Handle different error types
		switch {
		case errors.Is(err, ErrUserExists):
			h.respondError(w, http.StatusConflict, "user already exists", err)
		case errors.Is(err, ErrInvalidInput):
			h.respondError(w, http.StatusBadRequest, "invalid input", err)
		default:
			h.respondError(w, http.StatusInternalServerError, "internal server error", err)
		}
		return
	}

	// Success response
	resp := CreateUserResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
	}
	h.respondJSON(w, http.StatusCreated, resp)
}

// validateCreateUserRequest validates the request
func validateCreateUserRequest(req CreateUserRequest) error {
	if req.Name == "" {
		return fmt.Errorf("%w: name is required", ErrInvalidInput)
	}
	if req.Email == "" {
		return fmt.Errorf("%w: email is required", ErrInvalidInput)
	}
	return nil
}

// respondJSON sends a JSON response
func (h *Handler) respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(data); err != nil {
		h.logger.Printf("Error encoding response: %v", err)
	}
}

// respondError sends an error response
func (h *Handler) respondError(w http.ResponseWriter, status int, message string, err error) {
	if err != nil {
		h.logger.Printf("Error: %v", err)
	}

	resp := ErrorResponse{
		Error:   http.StatusText(status),
		Message: message,
	}

	h.respondJSON(w, status, resp)
}

// Example middleware for logging
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("%s %s", r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

// Example usage:
/*
func main() {
	service := NewUserService()
	logger := log.New(os.Stdout, "API: ", log.LstdFlags)
	handler := NewHandler(service, logger)

	mux := http.NewServeMux()
	mux.HandleFunc("/users", handler.CreateUserHandler)

	// Wrap with middleware
	server := &http.Server{
		Addr:    ":8080",
		Handler: loggingMiddleware(mux),
	}

	log.Fatal(server.ListenAndServe())
}
*/