package example

import (
	"reflect"
	"testing"
)

// Table-driven test template
func TestFunctionName(t *testing.T) {
	tests := []struct {
		name    string      // Descriptive name for the test case
		input   InputType   // Input to the function being tested
		want    OutputType  // Expected output
		wantErr bool        // Whether an error is expected
	}{
		{
			name:  "valid_input",
			input: InputType{}, // Provide valid input
			want:  OutputType{}, // Expected output
			wantErr: false,
		},
		{
			name:  "invalid_input",
			input: InputType{}, // Provide invalid input
			want:  OutputType{}, // Expected output for error case
			wantErr: true,
		},
		{
			name:  "edge_case_empty",
			input: InputType{}, // Edge case: empty input
			want:  OutputType{},
			wantErr: false,
		},
		{
			name:  "edge_case_nil",
			input: InputType{}, // Edge case: nil input
			want:  OutputType{},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := FunctionName(tt.input)

			// Check error expectation
			if (err != nil) != tt.wantErr {
				t.Errorf("FunctionName() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			// If we expected an error, don't check output
			if tt.wantErr {
				return
			}

			// Compare output
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("FunctionName() = %v, want %v", got, tt.want)
			}
		})
	}
}

// Example with multiple return values
func TestFunctionWithMultipleReturns(t *testing.T) {
	tests := []struct {
		name     string
		input    InputType
		wantVal1 Type1
		wantVal2 Type2
		wantErr  bool
	}{
		{
			name:     "success_case",
			input:    InputType{},
			wantVal1: Type1{},
			wantVal2: Type2{},
			wantErr:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotVal1, gotVal2, err := FunctionName(tt.input)

			if (err != nil) != tt.wantErr {
				t.Errorf("FunctionName() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !reflect.DeepEqual(gotVal1, tt.wantVal1) {
				t.Errorf("FunctionName() val1 = %v, want %v", gotVal1, tt.wantVal1)
			}

			if !reflect.DeepEqual(gotVal2, tt.wantVal2) {
				t.Errorf("FunctionName() val2 = %v, want %v", gotVal2, tt.wantVal2)
			}
		})
	}
}

// Helper function template (use t.Helper() for better error reporting)
func assertEqual(t *testing.T, got, want interface{}) {
	t.Helper() // Marks this as a helper function
	if !reflect.DeepEqual(got, want) {
		t.Errorf("\ngot:  %+v\nwant: %+v", got, want)
	}
}
