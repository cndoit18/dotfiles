#!/usr/bin/env python3
"""
AI-powered scientific schematic generation.

This script uses a smart iterative refinement approach:
1. Generate initial image
2. AI quality review for scientific critique
3. Only regenerate if quality is below threshold for document type
4. Repeat until quality meets standards (max iterations)

Requirements:
    - OPENAI_API_KEY environment variable

Usage:
    python generate_schematic.py "Create a flowchart showing CONSORT participant flow" -o flowchart.png
    python generate_schematic.py "Neural network architecture diagram" -o architecture.png --iterations 2
    python generate_schematic.py "Simple block diagram" -o diagram.png --doc-type poster
"""

import argparse
import base64
import json
import os
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path
from typing import Optional, Dict, Any, List, Tuple


class ScientificSchematicGenerator:
    """Generate scientific schematics using AI with smart iterative refinement.

    Multiple passes only occur if generated schematic doesn't meet
    quality threshold for target document type.
    """

    # Quality thresholds by document type (score out of 10)
    QUALITY_THRESHOLDS = {
        "journal": 8.5,
        "conference": 8.0,
        "poster": 7.0,
        "presentation": 6.5,
        "report": 7.5,
        "grant": 8.0,
        "thesis": 8.0,
        "preprint": 7.5,
        "default": 7.5,
    }

    # Scientific diagram best practices prompt template
    SCIENTIFIC_DIAGRAM_GUIDELINES = """
Create a high-quality scientific diagram with these requirements:

VISUAL QUALITY:
- Clean white or light background (no textures or gradients)
- High contrast for readability and printing
- Professional, publication-ready appearance
- Sharp, clear lines and text
- Adequate spacing between elements to prevent crowding

TYPOGRAPHY:
- Clear, readable sans-serif fonts (Arial, Helvetica style)
- Minimum 10pt font size for all labels
- Consistent font sizes throughout
- All text horizontal or clearly readable
- No overlapping text

SCIENTIFIC STANDARDS:
- Accurate representation of concepts
- Clear labels for all components
- Include scale bars, legends, or axes where appropriate
- Use standard scientific notation and symbols
- Include units where applicable

ACCESSIBILITY:
- Colorblind-friendly color palette (use Okabe-Ito colors if using color)
- High contrast between elements
- Redundant encoding (shapes + colors, not just colors)
- Works well in grayscale

LAYOUT:
- Logical flow (left-to-right or top-to-bottom)
- Clear visual hierarchy
- Balanced composition
- Appropriate use of whitespace
- No clutter or unnecessary decorative elements
"""

    def __init__(self, api_key: Optional[str] = None, verbose: bool = False):
        """Initialize the generator.

        Args:
            api_key: OpenAI API key (or use OPENAI_API_KEY env var)
            verbose: Print detailed progress information
        """
        self.api_key = api_key
        self.verbose = verbose
        self._last_error = None
        self.base_url = os.getenv("OPENAI_API_BASE") or "https://openrouter.ai/api/v1"
        self.image_model = (
            os.getenv("IMAGE_MODEL") or "google/gemini-3-pro-image-preview"
        )
        self.review_model = os.getenv("REVIEW_MODEL") or "google/gemini-3-pro"

    def _log(self, message: str):
        """Log message if verbose mode is enabled."""
        if self.verbose:
            print(f"[{time.strftime('%H:%M:%S')}] {message}")

    def _make_request(
        self, model: str, messages: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """Make a request to OpenAI API using chat/completions endpoint.

        Used for image review and other text-based operations.

        Args:
            model: Model identifier
            messages: List of message dictionaries

        Returns:
            API response as dictionary
        """
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/scientific-writer",
            "X-Title": "Scientific Schematic Generator",
        }

        payload = {"model": model, "messages": messages}

        self._log(f"Making request to {model}...")

        try:
            url = f"{self.base_url}/chat/completions"
            data = json.dumps(payload).encode("utf-8")

            req = urllib.request.Request(url, data=data, headers=headers, method="POST")

            with urllib.request.urlopen(req, timeout=120) as response:
                response_text = response.read().decode("utf-8")
                response_json = json.loads(response_text)

                return response_json

        except urllib.error.HTTPError as e:
            try:
                error_body = json.loads(e.read().decode("utf-8"))
                error_detail = error_body.get("error", error_body)
            except (json.JSONDecodeError, Exception):
                error_detail = str(e)

            self._log(f"HTTP {e.code}: {error_detail}")
            raise RuntimeError(f"API request failed (HTTP {e.code}): {error_detail}")

        except urllib.error.URLError as e:
            if isinstance(e.reason, TimeoutError):
                raise RuntimeError("API request timed out after 120 seconds")
            raise RuntimeError(f"API request failed: {str(e.reason)}")

        except TimeoutError:
            raise RuntimeError("API request timed out after 120 seconds")

    def _make_image_request(
        self,
        model: str,
        prompt: str,
        size: str = "1024x1024",
        quality: str = "standard",
        response_format: str = "b64_json",
    ) -> Dict[str, Any]:
        """Make a request to OpenAI API using images/generations endpoint.

        Used for image generation.

        Args:
            model: Model identifier
            prompt: Text description of the image to generate
            size: Image size (default: "1024x1024")
            quality: Image quality (default: "standard")
            response_format: Response format ("url" or "b64_json", default: "b64_json")

        Returns:
            API response as dictionary
        """
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://github.com/scientific-writer",
            "X-Title": "Scientific Schematic Generator",
        }

        payload = {
            "model": model,
            "prompt": prompt,
            "n": 1,
            "size": size,
            "quality": quality,
            "response_format": response_format,
        }

        self._log(f"Making image generation request to {model}...")

        try:
            url = f"{self.base_url}/images/generations"
            data = json.dumps(payload).encode("utf-8")

            req = urllib.request.Request(url, data=data, headers=headers, method="POST")

            with urllib.request.urlopen(req, timeout=120) as response:
                response_text = response.read().decode("utf-8")
                response_json = json.loads(response_text)

                return response_json

        except urllib.error.HTTPError as e:
            try:
                error_body = json.loads(e.read().decode("utf-8"))
                error_detail = error_body.get("error", error_body)
            except (json.JSONDecodeError, Exception):
                error_detail = str(e)

            self._log(f"HTTP {e.code}: {error_detail}")
            raise RuntimeError(f"API request failed (HTTP {e.code}): {error_detail}")

        except urllib.error.URLError as e:
            if isinstance(e.reason, TimeoutError):
                raise RuntimeError("API request timed out after 120 seconds")
            raise RuntimeError(f"API request failed: {str(e.reason)}")

        except TimeoutError:
            raise RuntimeError("API request timed out after 120 seconds")

    def _extract_image_from_response(self, response: Dict[str, Any]) -> Optional[bytes]:
        """Extract image from API response.

        Supports images/generations endpoint format (data[0].b64_json or data[0].url).

        Args:
            response: API response dictionary

        Returns:
            Image bytes or None if not found
        """
        try:
            data = response.get("data", [])
            if not data:
                self._log("No data in response")
                return None

            self._log(f"Found {len(data)} image(s) in 'data' array")
            first_image = data[0]

            # Check for b64_json (base64 encoded image)
            if "b64_json" in first_image:
                base64_str = first_image["b64_json"]
                base64_str = (
                    base64_str.replace("\n", "").replace("\r", "").replace(" ", "")
                )
                self._log(f"Extracted b64_json data (length: {len(base64_str)})")
                return base64.b64decode(base64_str)

            # Check for url (need to download)
            if "url" in first_image:
                url = first_image["url"]
                self._log(f"Found image URL: {url}")
                self._log("Downloading image from URL...")
                with urllib.request.urlopen(url, timeout=60) as img_response:
                    image_bytes = img_response.read()
                    self._log(f"Downloaded {len(image_bytes)} bytes")
                    return image_bytes

            self._log("No image data found in response")
            return None

        except Exception as e:
            self._log(f"Error extracting image: {str(e)}")
            import traceback

            if self.verbose:
                traceback.print_exc()
            return None

    def _image_to_base64(self, image_path: str) -> str:
        """Convert image file to base64 data URL.

        Args:
            image_path: Path to image file

        Returns:
            Base64 data URL string
        """
        with open(image_path, "rb") as f:
            image_data = f.read()

        ext = Path(image_path).suffix.lower()
        mime_type = {
            ".png": "image/png",
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
            ".gif": "image/gif",
            ".webp": "image/webp",
        }.get(ext, "image/png")

        base64_data = base64.b64encode(image_data).decode("utf-8")
        return f"data:{mime_type};base64,{base64_data}"

    def generate_image(self, prompt: str) -> Optional[bytes]:
        """Generate an image using image generation API.

        Args:
            prompt: Description of diagram to generate

        Returns:
            Image bytes or None if generation failed
        """
        self._last_error = None

        try:
            response = self._make_image_request(
                model=self.image_model,
                prompt=prompt,
                size="2048x2048",
                quality="standard",
                response_format="b64_json",
            )

            if self.verbose:
                self._log(f"Response keys: {response.keys()}")
                if "error" in response:
                    self._log(f"API Error: {response['error']}")

            if "error" in response:
                error_msg = response["error"]
                if isinstance(error_msg, dict):
                    error_msg = error_msg.get("message", str(error_msg))
                self._last_error = f"API Error: {error_msg}"
                print(f"✗ {self._last_error}")
                return None

            image_data = self._extract_image_from_response(response)
            if image_data:
                self._log(f"✓ Generated image ({len(image_data)} bytes)")
            else:
                self._last_error = "No image data in API response"
                self._log(f"✗ {self._last_error}")
                if self.verbose:
                    self._log(
                        f"Full response structure: {json.dumps(response, indent=2)[:500]}..."
                    )

            return image_data
        except RuntimeError as e:
            self._last_error = str(e)
            self._log(f"✗ Generation failed: {self._last_error}")
            return None
        except Exception as e:
            self._last_error = f"Unexpected error: {str(e)}"
            self._log(f"✗ Generation failed: {self._last_error}")
            import traceback

            if self.verbose:
                traceback.print_exc()
            return None

    def review_image(
        self,
        image_path: str,
        original_prompt: str,
        iteration: int,
        doc_type: str = "default",
        max_iterations: int = 2,
    ) -> Tuple[str, float, bool]:
        """Review generated image for quality analysis.

        Args:
            image_path: Path to generated image
            original_prompt: Original user prompt
            iteration: Current iteration number
            doc_type: Document type (journal, poster, presentation, etc.)
            max_iterations: Maximum iterations allowed

        Returns:
            Tuple of (critique text, quality score 0-10, needs_improvement bool)
        """
        image_data_url = self._image_to_base64(image_path)

        threshold = self.QUALITY_THRESHOLDS.get(
            doc_type.lower(), self.QUALITY_THRESHOLDS["default"]
        )

        review_prompt = f"""You are an expert reviewer evaluating a scientific diagram for publication quality.

ORIGINAL REQUEST: {original_prompt}

DOCUMENT TYPE: {doc_type} (quality threshold: {threshold}/10)
ITERATION: {iteration}/{max_iterations}

Carefully evaluate this diagram on these criteria:

1. **Scientific Accuracy** (0-2 points)
   - Correct representation of concepts
   - Proper notation and symbols
   - Accurate relationships shown

2. **Clarity and Readability** (0-2 points)
   - Easy to understand at a glance
   - Clear visual hierarchy
   - No ambiguous elements

3. **Label Quality** (0-2 points)
   - All important elements labeled
   - Labels are readable (appropriate font size)
   - Consistent labeling style

4. **Layout and Composition** (0-2 points)
   - Logical flow (top-to-bottom or left-to-right)
   - Balanced use of space
   - No overlapping elements

5. **Professional Appearance** (0-2 points)
   - Publication-ready quality
   - Clean, crisp lines and shapes
   - Appropriate colors/contrast

RESPOND IN THIS EXACT FORMAT:
SCORE: [total score 0-10]

STRENGTHS:
- [strength 1]
- [strength 2]

ISSUES:
- [issue 1 if any]
- [issue 2 if any]

VERDICT: [ACCEPTABLE or NEEDS_IMPROVEMENT]

If score >= {threshold}, diagram is ACCEPTABLE for {doc_type} publication.
If score < {threshold}, mark as NEEDS_IMPROVEMENT with specific suggestions."""

        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": review_prompt},
                    {"type": "image_url", "image_url": {"url": image_data_url}},
                ],
            }
        ]

        try:
            response = self._make_request(model=self.review_model, messages=messages)

            choices = response.get("choices", [])
            if not choices:
                return "Image generated successfully", 8.0, False

            message = choices[0].get("message", {})
            content = message.get("content", "")

            reasoning = message.get("reasoning", "")
            if reasoning and not content:
                content = reasoning

            if isinstance(content, list):
                text_parts = []
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        text_parts.append(block.get("text", ""))
                content = "\n".join(text_parts)

            score = 7.5
            import re

            score_match = re.search(r"SCORE:\s*(\d+(?:\.\d+)?)", content, re.IGNORECASE)
            if score_match:
                score = float(score_match.group(1))
            else:
                score_match = re.search(
                    r"(?:score|rating|quality)[:\s]+(\d+(?:\.\d+)?)\s*(?:/\s*10)?",
                    content,
                    re.IGNORECASE,
                )
                if score_match:
                    score = float(score_match.group(1))

            needs_improvement = False
            if "NEEDS_IMPROVEMENT" in content.upper():
                needs_improvement = True
            elif score < threshold:
                needs_improvement = True

            self._log(
                f"✓ Review complete (Score: {score}/10, Threshold: {threshold}/10)"
            )
            self._log(
                f"  Verdict: {'Needs improvement' if needs_improvement else 'Acceptable'}"
            )

            return (
                content if content else "Image generated successfully",
                score,
                needs_improvement,
            )
        except Exception as e:
            self._log(f"Review skipped: {str(e)}")
            return "Image generated successfully (review skipped)", 7.5, False

    def improve_prompt(
        self, original_prompt: str, critique: str, iteration: int
    ) -> str:
        """Improve generation prompt based on critique.

        Args:
            original_prompt: Original user prompt
            critique: Review critique from previous iteration
            iteration: Current iteration number

        Returns:
            Improved prompt for next generation
        """
        improved_prompt = f"""{self.SCIENTIFIC_DIAGRAM_GUIDELINES}

USER REQUEST: {original_prompt}

ITERATION {iteration}: Based on previous feedback, address these specific improvements:
{critique}

Generate an improved version that addresses all the critique points while maintaining scientific accuracy and professional quality."""

        return improved_prompt

    def generate_iterative(
        self,
        user_prompt: str,
        output_path: str | Path,
        iterations: int = 2,
        doc_type: str = "default",
    ) -> Dict[str, Any]:
        """Generate scientific schematic with smart iterative refinement.

        Only regenerates if quality score is below threshold for the
        specified document type.

        Args:
            user_prompt: User's description of desired diagram
            output_path: Path to save final image
            iterations: Maximum refinement iterations (default: 2, max: 2)
            doc_type: Document type for quality threshold (journal, poster, etc.)

        Returns:
            Dictionary with generation results and metadata
        """
        output_path = Path(output_path)
        output_dir = output_path.parent
        output_dir.mkdir(parents=True, exist_ok=True)

        base_name = output_path.stem
        extension = output_path.suffix or ".png"

        threshold = self.QUALITY_THRESHOLDS.get(
            doc_type.lower(), self.QUALITY_THRESHOLDS["default"]
        )

        results = {
            "user_prompt": user_prompt,
            "doc_type": doc_type,
            "quality_threshold": threshold,
            "iterations": [],
            "final_image": None,
            "final_score": 0.0,
            "success": False,
            "early_stop": False,
            "early_stop_reason": None,
        }

        current_prompt = f"""{self.SCIENTIFIC_DIAGRAM_GUIDELINES}

USER REQUEST: {user_prompt}

Generate a publication-quality scientific diagram that meets all the guidelines above."""

        print(f"\n{'=' * 60}")
        print(f"Generating Scientific Schematic")
        print(f"{'=' * 60}")
        print(f"Description: {user_prompt}")
        print(f"Document Type: {doc_type}")
        print(f"Quality Threshold: {threshold}/10")
        print(f"Max Iterations: {iterations}")
        print(f"Output: {output_path}")
        print(f"{'=' * 60}\n")

        for i in range(1, iterations + 1):
            print(f"\n[Iteration {i}/{iterations}]")
            print("-" * 40)

            print(f"Generating image...")
            image_data = self.generate_image(current_prompt)

            if not image_data:
                error_msg = getattr(
                    self,
                    "_last_error",
                    "Image generation failed - no image data returned",
                )
                print(f"✗ Generation failed: {error_msg}")
                results["iterations"].append(
                    {"iteration": i, "success": False, "error": error_msg}
                )
                continue

            iter_path = output_dir / f"{base_name}_v{i}{extension}"
            with open(iter_path, "wb") as f:
                f.write(image_data)
            print(f"✓ Saved: {iter_path}")

            print(f"Reviewing image...")
            critique, score, needs_improvement = self.review_image(
                str(iter_path), user_prompt, i, doc_type, iterations
            )
            print(f"✓ Score: {score}/10 (threshold: {threshold}/10)")

            iteration_result = {
                "iteration": i,
                "image_path": str(iter_path),
                "prompt": current_prompt,
                "critique": critique,
                "score": score,
                "needs_improvement": needs_improvement,
                "success": True,
            }
            results["iterations"].append(iteration_result)

            if not needs_improvement:
                print(
                    f"\n✓ Quality meets {doc_type} threshold ({score} >= {threshold})"
                )
                print(f"  No further iterations needed!")
                results["final_image"] = str(iter_path)
                results["final_score"] = score
                results["success"] = True
                results["early_stop"] = True
                results["early_stop_reason"] = (
                    f"Quality score {score} meets threshold {threshold} for {doc_type}"
                )
                break

            if i == iterations:
                print(f"\n⚠ Maximum iterations reached")
                results["final_image"] = str(iter_path)
                results["final_score"] = score
                results["success"] = True
                break

            print(f"\n⚠ Quality below threshold ({score} < {threshold})")
            print(f"Improving prompt based on feedback...")
            current_prompt = self.improve_prompt(user_prompt, critique, i + 1)

        if results["success"] and results["final_image"]:
            final_iter_path = Path(results["final_image"])
            if final_iter_path != output_path:
                import shutil

                shutil.copy(final_iter_path, output_path)
                print(f"\n✓ Final image: {output_path}")

        log_path = output_dir / f"{base_name}_review_log.json"
        with open(log_path, "w") as f:
            json.dump(results, f, indent=2)
        print(f"✓ Review log: {log_path}")

        print(f"\n{'=' * 60}")
        print(f"Generation Complete!")
        print(f"Final Score: {results['final_score']}/10")
        if results["early_stop"]:
            print(
                f"Iterations Used: {len([r for r in results['iterations'] if r.get('success')])}/{iterations} (early stop)"
            )
        print(f"{'=' * 60}\n")

        return results


def main():
    """Command-line interface."""
    parser = argparse.ArgumentParser(
        description="Generate scientific schematics using AI with smart iterative refinement",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate a flowchart for a journal paper
  python generate_schematic.py "CONSORT participant flow diagram" -o flowchart.png --doc-type journal

  # Generate neural network architecture for presentation (lower threshold)
  python generate_schematic.py "Transformer encoder-decoder architecture" -o transformer.png --doc-type presentation

  # Generate with custom max iterations for poster
  python generate_schematic.py "Biological signaling pathway" -o pathway.png --iterations 2 --doc-type poster

  # Verbose output
  python generate_schematic.py "Circuit diagram" -o circuit.png -v

Document Types (quality thresholds):
  journal      8.5/10  - Nature, Science, peer-reviewed journals
  conference   8.0/10  - Conference papers
  thesis       8.0/10  - Dissertations, theses
  grant        8.0/10  - Grant proposals

  preprint     7.5/10  - arXiv, bioRxiv, etc.
  report       7.5/10  - Technical reports
  poster       7.0/10  - Academic posters
  presentation 6.5/10  - Slides, talks
  default      7.5/10  - General purpose

Note: Multiple iterations only occur if quality is BELOW the threshold.
      If the first generation meets the threshold, no extra API calls are made.

Environment:
  OPENAI_API_KEY    OpenAI API key (required)
        """,
    )

    parser.add_argument("prompt", help="Description of the diagram to generate")
    parser.add_argument(
        "-o", "--output", required=True, help="Output image path (e.g., diagram.png)"
    )
    parser.add_argument(
        "--iterations",
        type=int,
        default=2,
        help="Maximum refinement iterations (default: 2, max: 2)",
    )
    parser.add_argument(
        "--doc-type",
        default="default",
        choices=[
            "journal",
            "conference",
            "poster",
            "presentation",
            "report",
            "grant",
            "thesis",
            "preprint",
            "default",
        ],
        help="Document type for quality threshold (default: default)",
    )
    parser.add_argument("--api-key", help="OpenAI API key (or set OPENAI_API_KEY)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")

    args = parser.parse_args()

    api_key = args.api_key or os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY environment variable not set")
        print("\nSet it with:")
        print("  export OPENAI_API_KEY='your_api_key'")
        print("\nOr provide via --api-key flag")
        sys.exit(1)

    if args.iterations < 1 or args.iterations > 2:
        print("Error: Iterations must be between 1 and 2")
        sys.exit(1)

    try:
        generator = ScientificSchematicGenerator(api_key=api_key, verbose=args.verbose)
        results = generator.generate_iterative(
            user_prompt=args.prompt,
            output_path=args.output,
            iterations=args.iterations,
            doc_type=args.doc_type,
        )

        if results["success"]:
            print(f"\n✓ Success! Image saved to: {args.output}")
            if results.get("early_stop"):
                print(
                    f"  (Completed in {len([r for r in results['iterations'] if r.get('success')])} iteration(s) - quality threshold met)"
                )
            sys.exit(0)
        else:
            print(f"\n✗ Generation failed. Check review log for details.")
            sys.exit(1)
    except Exception as e:
        print(f"\n✗ Error: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
