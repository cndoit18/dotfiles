#!/usr/bin/env python3
"""
Prompt Optimization Script

Automatically test and optimize prompts using A/B testing and metrics tracking.
"""

import json
import time
import os
import argparse
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import numpy as np
from openai import OpenAI
import openai


@dataclass
class TestCase:
    input: Dict[str, Any]
    expected_output: str
    metadata: Optional[Dict[str, Any]] = None


class PromptOptimizer:
    def __init__(self, llm_client, test_suite: List[TestCase]):
        self.client = llm_client
        self.test_suite = test_suite
        self.results_history = []
        self.executor = ThreadPoolExecutor()

    def shutdown(self):
        """Shutdown the thread pool executor."""
        self.executor.shutdown(wait=True)

    def evaluate_prompt(
        self, prompt_template: str, test_cases: Optional[List[TestCase]] = None
    ) -> Dict[str, float]:
        """Evaluate a prompt template against test cases in parallel."""
        if test_cases is None:
            test_cases = self.test_suite

        metrics = {"accuracy": [], "latency": [], "token_count": [], "success_rate": []}

        def process_test_case(test_case):
            start_time = time.time()

            # Render prompt with test case inputs
            prompt = prompt_template.format(**test_case.input)

            # Get LLM response
            response = self.client.complete(prompt)

            # Measure latency
            latency = time.time() - start_time

            # Calculate individual metrics
            token_count = len(prompt.split()) + len(response.split())
            success = 1 if response else 0
            accuracy = self.calculate_accuracy(response, test_case.expected_output)

            return {
                "latency": latency,
                "token_count": token_count,
                "success_rate": success,
                "accuracy": accuracy,
            }

        # Run test cases in parallel
        results = list(self.executor.map(process_test_case, test_cases))

        # Aggregate metrics
        for result in results:
            metrics["latency"].append(result["latency"])
            metrics["token_count"].append(result["token_count"])
            metrics["success_rate"].append(result["success_rate"])
            metrics["accuracy"].append(result["accuracy"])

        return {
            "avg_accuracy": np.mean(metrics["accuracy"]),
            "avg_latency": np.mean(metrics["latency"]),
            "p95_latency": np.percentile(metrics["latency"], 95),
            "avg_tokens": np.mean(metrics["token_count"]),
            "success_rate": np.mean(metrics["success_rate"]),
        }

    def calculate_accuracy(self, response: str, expected: str) -> float:
        """Calculate accuracy score between response and expected output."""
        # Simple exact match
        if response.strip().lower() == expected.strip().lower():
            return 1.0

        # Partial match using word overlap
        response_words = set(response.lower().split())
        expected_words = set(expected.lower().split())

        if not expected_words:
            return 0.0

        overlap = len(response_words & expected_words)
        return overlap / len(expected_words)

    def optimize(self, base_prompt: str, max_iterations: int = 5) -> Dict[str, Any]:
        """Iteratively optimize a prompt."""
        current_prompt = base_prompt
        best_prompt = base_prompt
        best_score = 0
        current_metrics = None

        for iteration in range(max_iterations):
            print(f"\nIteration {iteration + 1}/{max_iterations}")

            # Evaluate current prompt
            # Bolt Optimization: Avoid re-evaluating if we already have metrics from previous iteration
            if current_metrics:
                metrics = current_metrics
            else:
                metrics = self.evaluate_prompt(current_prompt)

            print(
                f"Accuracy: {metrics['avg_accuracy']:.2f}, Latency: {metrics['avg_latency']:.2f}s"
            )

            # Track results
            self.results_history.append(
                {"iteration": iteration, "prompt": current_prompt, "metrics": metrics}
            )

            # Update best if improved
            if metrics["avg_accuracy"] > best_score:
                best_score = metrics["avg_accuracy"]
                best_prompt = current_prompt

            # Stop if good enough
            if metrics["avg_accuracy"] > 0.95:
                print("Achieved target accuracy!")
                break

            # Generate variations for next iteration
            variations = self.generate_variations(current_prompt, metrics)

            # Test variations and pick best
            best_variation = current_prompt
            best_variation_score = metrics["avg_accuracy"]
            best_variation_metrics = metrics

            for variation in variations:
                var_metrics = self.evaluate_prompt(variation)
                if var_metrics["avg_accuracy"] > best_variation_score:
                    best_variation_score = var_metrics["avg_accuracy"]
                    best_variation = variation
                    best_variation_metrics = var_metrics

            current_prompt = best_variation
            current_metrics = best_variation_metrics

        return {
            "best_prompt": best_prompt,
            "best_score": best_score,
            "history": self.results_history,
        }

    def generate_variations(self, prompt: str, current_metrics: Dict) -> List[str]:
        """Generate prompt variations to test."""
        variations = []

        # Variation 1: Add explicit format instruction
        variations.append(
            prompt + "\n\nProvide your answer in a clear, concise format."
        )

        # Variation 2: Add step-by-step instruction
        variations.append("Let's solve this step by step.\n\n" + prompt)

        # Variation 3: Add verification step
        variations.append(prompt + "\n\nVerify your answer before responding.")

        # Variation 4: Make more concise
        concise = self.make_concise(prompt)
        if concise != prompt:
            variations.append(concise)

        # Variation 5: Add examples (if none present)
        if "example" not in prompt.lower():
            variations.append(self.add_examples(prompt))

        return variations[:3]  # Return top 3 variations

    def make_concise(self, prompt: str) -> str:
        """Remove redundant words to make prompt more concise."""
        replacements = [
            ("in order to", "to"),
            ("due to the fact that", "because"),
            ("at this point in time", "now"),
            ("in the event that", "if"),
        ]

        result = prompt
        for old, new in replacements:
            result = result.replace(old, new)

        return result

    def add_examples(self, prompt: str) -> str:
        """Add example section to prompt."""
        return f"""{prompt}

Example:
Input: Sample input
Output: Sample output
"""

    def compare_prompts(self, prompt_a: str, prompt_b: str) -> Dict[str, Any]:
        """A/B test two prompts."""
        print("Testing Prompt A...")
        metrics_a = self.evaluate_prompt(prompt_a)

        print("Testing Prompt B...")
        metrics_b = self.evaluate_prompt(prompt_b)

        return {
            "prompt_a_metrics": metrics_a,
            "prompt_b_metrics": metrics_b,
            "winner": "A"
            if metrics_a["avg_accuracy"] > metrics_b["avg_accuracy"]
            else "B",
            "improvement": abs(metrics_a["avg_accuracy"] - metrics_b["avg_accuracy"]),
        }

    def export_results(self, filename: str):
        """Export optimization results to JSON."""
        with open(filename, "w") as f:
            json.dump(self.results_history, f, indent=2)


def create_default_test_suite() -> List[TestCase]:
    """Create a default test suite for sentiment analysis."""
    return [
        TestCase(
            input={"text": "This product is amazing! I love it."},
            expected_output="Positive",
        ),
        TestCase(
            input={"text": "Terrible quality, would not recommend."},
            expected_output="Negative",
        ),
        TestCase(
            input={"text": "The product arrived on time."}, expected_output="Neutral"
        ),
        TestCase(
            input={"text": "I'm so disappointed with this purchase."},
            expected_output="Negative",
        ),
        TestCase(
            input={"text": "It works exactly as described."}, expected_output="Neutral"
        ),
    ]


def load_test_suite_from_file(file_path: str) -> List[TestCase]:
    """Load test cases from a JSON file."""
    try:
        with open(file_path, "r") as f:
            data = json.load(f)

        test_cases = []
        # Handle different JSON structures
        if isinstance(data, list):
            for item in data:
                if (
                    isinstance(item, dict)
                    and "input" in item
                    and "expected_output" in item
                ):
                    test_cases.append(
                        TestCase(
                            input=item["input"],
                            expected_output=item["expected_output"],
                            metadata=item.get("metadata"),
                        )
                    )
        elif isinstance(data, dict):
            # Look for test cases in common keys
            for key in ["test_cases", "tests", "sentiment_analysis"]:
                if key in data and isinstance(data[key], list):
                    for item in data[key]:
                        if (
                            isinstance(item, dict)
                            and "input" in item
                            and "expected_output" in item
                        ):
                            test_cases.append(
                                TestCase(
                                    input=item["input"],
                                    expected_output=item["expected_output"],
                                    metadata=item.get("metadata"),
                                )
                            )

        if not test_cases:
            print(f"Warning: No valid test cases found in {file_path}")
            return create_default_test_suite()

        print(f"Loaded {len(test_cases)} test cases from {file_path}")
        return test_cases

    except Exception as e:
        print(f"Error loading test suite from {file_path}: {e}")
        print("Using default test suite instead.")
        return create_default_test_suite()


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Optimize prompts using A/B testing and metrics tracking."
    )

    parser.add_argument(
        "--test-suite", type=str, help="Path to JSON file containing test cases"
    )

    parser.add_argument(
        "--base-prompt",
        type=str,
        default="Classify the sentiment of: {text}\nSentiment:",
        help="Base prompt template to optimize",
    )

    parser.add_argument(
        "--max-iterations",
        type=int,
        default=5,
        help="Maximum number of optimization iterations",
    )

    parser.add_argument(
        "--output",
        type=str,
        default="optimization_results.json",
        help="Output file for optimization results",
    )

    return parser.parse_args()


def main():
    args = parse_arguments()

    # Load test suite
    if args.test_suite:
        test_suite = load_test_suite_from_file(args.test_suite)
    else:
        test_suite = create_default_test_suite()
        print("Using default test suite for sentiment analysis.")

    class OpenAILLMClient:
        def __init__(self, model="gpt-3.5-turbo", max_tokens=50, temperature=0.0):
            self.client = OpenAI(
                base_url=os.getenv("OPENAI_API_BASE"),
                api_key=os.getenv("OPENAI_API_KEY"),
            )
            self.model = os.getenv("DEFAULT_MODEL") or model
            self.max_tokens = max_tokens
            self.temperature = temperature

        def complete(self, prompt):
            try:
                response = self.client.chat.completions.create(
                    model=self.model,
                    messages=[
                        {
                            "role": "system",
                            "content": "You are a sentiment classifier. Respond with only 'Positive', 'Negative', or 'Neutral'.",
                        },
                        {"role": "user", "content": prompt},
                    ],
                    max_tokens=self.max_tokens,
                    temperature=self.temperature,
                )
                return response.choices[0].message.content
            except openai.APIConnectionError as e:
                print(f"Server connection failed: {e}")
                return ""
            except openai.RateLimitError as e:
                print(f"Rate limit exceeded: {e}")
                return ""
            except openai.AuthenticationError as e:
                print(f"Invalid API key: {e}")
                return ""
            except openai.BadRequestError as e:
                print(f"Bad request: {e}")
                return ""
            except openai.APIStatusError as e:
                print(f"API error: {e}")
                return ""
            except openai.OpenAIError as e:
                print(f"General OpenAI error: {e}")
                return ""

    optimizer = PromptOptimizer(OpenAILLMClient(), test_suite)

    try:
        print("Starting prompt optimization...")
        print(f"Base prompt: {args.base_prompt}")
        print(f"Test cases: {len(test_suite)}")
        print(f"Max iterations: {args.max_iterations}")

        results = optimizer.optimize(args.base_prompt, args.max_iterations)

        print("\n" + "=" * 50)
        print("Optimization Complete!")
        print(f"Best Accuracy: {results['best_score']:.2f}")
        print(f"Best Prompt:\n{results['best_prompt']}")

        optimizer.export_results(args.output)
        print(f"Results exported to {args.output}")
    finally:
        optimizer.shutdown()


if __name__ == "__main__":
    main()
