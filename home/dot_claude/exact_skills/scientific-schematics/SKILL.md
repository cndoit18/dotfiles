---
name: scientific-schematics
description: "Create publication-quality scientific diagrams using AI with smart iterative refinement. Uses AI quality review. Only regenerates if quality is below threshold for your document type. Specialized in neural network architectures, system diagrams, flowcharts, biological pathways, and complex scientific visualizations."
allowed-tools: [Read, Write, Edit, Bash]
---

# Scientific Schematics and Diagrams

## Overview

Generate publication-quality scientific diagrams using AI with smart iterative refinement.

**How it works:**

- Describe your diagram in natural language
- AI generates publication-quality images
- **AI reviews quality** against document-type thresholds
- **Smart iteration**: Only regenerates if quality is below threshold
- Publication-ready output in minutes
- No coding, templates, or manual drawing required

**Quality Thresholds by Document Type:**

| Document Type | Threshold | Description                             |
| ------------- | --------- | --------------------------------------- |
| journal       | 8.5/10    | Nature, Science, peer-reviewed journals |
| conference    | 8.0/10    | Conference papers                       |
| thesis        | 8.0/10    | Dissertations, theses                   |
| grant         | 8.0/10    | Grant proposals                         |
| preprint      | 7.5/10    | arXiv, bioRxiv, etc.                    |
| report        | 7.5/10    | Technical reports                       |
| poster        | 7.0/10    | Academic posters                        |
| presentation  | 6.5/10    | Slides, talks                           |
| default       | 7.5/10    | General purpose                         |

## Quick Start

Create any scientific diagram by simply describing it:

```bash
# Generate for journal paper (highest quality threshold: 8.5/10)
python scripts/generate_schematic.py "CONSORT participant flow diagram with 500 screened, 150 excluded, 350 randomized" -o figures/consort.png --doc-type journal

# Generate for presentation (lower threshold: 6.5/10 - faster)
python scripts/generate_schematic.py "Transformer encoder-decoder architecture showing multi-head attention" -o figures/transformer.png --doc-type presentation

# Generate for poster (moderate threshold: 7.0/10)
python scripts/generate_schematic.py "MAPK signaling pathway from EGFR to gene transcription" -o figures/mapk_pathway.png --doc-type poster

# Custom max iterations (max 2)
python scripts/generate_schematic.py "Complex circuit diagram with op-amp, resistors, and capacitors" -o figures/circuit.png --iterations 2 --doc-type journal
```

**What happens behind the scenes:**

1. **Generation 1**: AI creates initial image following scientific diagram best practices
2. **Review 1**: AI evaluates quality against document-type threshold
3. **Decision**: If quality >= threshold → **DONE** (no more iterations needed!)
4. **If below threshold**: Improved prompt based on critique, regenerate
5. **Repeat**: Until quality meets threshold OR max iterations reached

**Smart Iteration Benefits:**

- ✅ Saves API calls if first generation is good enough
- ✅ Higher quality standards for journal papers
- ✅ Faster turnaround for presentations/posters
- ✅ Appropriate quality for each use case

**Output**: Versioned images plus a detailed review log with quality scores, critiques, and early-stop information.

## Command-Line Options

```bash
# Basic usage (default threshold 7.5/10)
python scripts/generate_schematic.py "diagram description" -o output.png

# Specify document type for appropriate quality threshold
python scripts/generate_schematic.py "diagram" -o out.png --doc-type journal      # 8.5/10
python scripts/generate_schematic.py "diagram" -o out.png --doc-type conference   # 8.0/10
python scripts/generate_schematic.py "diagram" -o out.png --doc-type poster       # 7.0/10
python scripts/generate_schematic.py "diagram" -o out.png --doc-type presentation # 6.5/10

# Custom max iterations (1-2)
python scripts/generate_schematic.py "complex diagram" -o diagram.png --iterations 2

# Verbose output (see all API calls and reviews)
python scripts/generate_schematic.py "flowchart" -o flow.png -v

# Provide API key via flag
python scripts/generate_schematic.py "diagram" -o out.png --api-key "sk-or-v1-..."

# Combine options
python scripts/generate_schematic.py "neural network" -o nn.png --doc-type journal --iterations 2 -v
```

## AI Generation Best Practices

**Effective Prompts for Scientific Diagrams:**

✓ **Good prompts** (specific, detailed):

- "CONSORT flowchart showing participant flow from screening (n=500) through randomization to final analysis"
- "Transformer neural network architecture with encoder stack on left, decoder stack on right, showing multi-head attention and cross-attention connections"
- "Biological signaling cascade: EGFR receptor → RAS → RAF → MEK → ERK → nucleus, with phosphorylation steps labeled"
- "Block diagram of IoT system: sensors → microcontroller → WiFi module → cloud server → mobile app"

✗ **Avoid vague prompts**:

- "Make a flowchart" (too generic)
- "Neural network" (which type? what components?)
- "Pathway diagram" (which pathway? what molecules?)

**Key elements to include:**

- **Type**: Flowchart, architecture diagram, pathway, circuit, etc.
- **Components**: Specific elements to include
- **Flow/Direction**: How elements connect (left-to-right, top-to-bottom)
- **Labels**: Key annotations or text to include
- **Style**: Any specific visual requirements

**Scientific Quality Guidelines** (automatically applied):

- Clean white/light background
- High contrast for readability
- Clear, readable labels (minimum 10pt)
- Professional typography (sans-serif fonts)
- Colorblind-friendly colors (Okabe-Ito palette)
- Proper spacing to prevent crowding
- Scale bars, legends, axes where appropriate

## Examples

### Example 1: CONSORT Flowchart

```bash
python scripts/generate_schematic.py \
  "CONSORT participant flow diagram for randomized controlled trial. \
  Start with 'Assessed for eligibility (n=500)' at top. \
  Show 'Excluded (n=150)' with reasons: age<18 (n=80), declined (n=50), other (n=20). \
  Then 'Randomized (n=350)' splits into two arms: \
  'Treatment group (n=175)' and 'Control group (n=175)'. \
  Each arm shows 'Lost to follow-up' (n=15 and n=10). \
  End with 'Analyzed' (n=160 and n=165). \
  Use blue boxes for process steps, orange for exclusion, green for final analysis." \
  -o figures/consort.png
```

### Example 2: Neural Network Architecture

```bash
python scripts/generate_schematic.py \
  "Transformer encoder-decoder architecture diagram. \
  Left side: Encoder stack with input embedding, positional encoding, \
  multi-head self-attention, add & norm, feed-forward. \
  Right side: Decoder stack with output embedding, positional encoding, \
  masked self-attention, add & norm, cross-attention (receiving from encoder), \
  add & norm, feed-forward, add & norm, linear & softmax. \
  Show cross-attention connection from encoder to decoder with dashed line. \
  Use light blue for encoder, light red for decoder. \
  Label all components clearly." \
  -o figures/transformer.png --iterations 2
```

### Example 3: Biological Pathway

```bash
python scripts/generate_schematic.py \
  "MAPK signaling pathway diagram. \
  Start with EGFR receptor at cell membrane (top). \
  Arrow down to RAS (with GTP label). \
  Arrow to RAF kinase. \
  Arrow to MEK kinase. \
  Arrow to ERK kinase. \
  Final arrow to nucleus showing gene transcription. \
  Label each arrow with 'phosphorylation' or 'activation'. \
  Use rounded rectangles for proteins, different colors for each. \
  Include membrane boundary line at top." \
  -o figures/mapk_pathway.png
```

### Example 4: System Architecture

```bash
python scripts/generate_schematic.py \
  "IoT system architecture block diagram. \
  Bottom layer: Sensors (temperature, humidity, motion) in green boxes. \
  Middle layer: Microcontroller (ESP32) in blue box. \
  Connections to WiFi module (orange box) and Display (purple box). \
  Top layer: Cloud server (gray box) connected to mobile app (light blue box). \
  Show data flow arrows between all components. \
  Label connections with protocols: I2C, UART, WiFi, HTTPS." \
  -o figures/iot_architecture.png
```

## When to Use This Skill

This skill should be used when:

- Creating neural network architecture diagrams (Transformers, CNNs, RNNs, etc.)
- Illustrating system architectures and data flow diagrams
- Drawing methodology flowcharts for study design (CONSORT, PRISMA)
- Visualizing algorithm workflows and processing pipelines
- Creating circuit diagrams and electrical schematics
- Depicting biological pathways and molecular interactions
- Generating network topologies and hierarchical structures
- Illustrating conceptual frameworks and theoretical models
- Designing block diagrams for technical papers

## Integration with Other Skills

This skill works synergistically with:

- **Scientific Writing** - Diagrams follow figure best practices
- **Scientific Visualization** - Shares color palettes and styling
- **LaTeX Posters** - Generate diagrams for poster presentations
- **Research Grants** - Methodology diagrams for proposals
- **Peer Review** - Evaluate diagram clarity and accessibility

## Quick Reference Checklist

Before submitting diagrams, verify:

### Visual Quality

- [ ] High-quality image format (PNG from AI generation)
- [ ] No overlapping elements (AI handles automatically)
- [ ] Adequate spacing between all components (AI optimizes)
- [ ] Clean, professional alignment
- [ ] All arrows connect properly to intended targets

### Accessibility

- [ ] Colorblind-safe palette (Okabe-Ito) used
- [ ] Works in grayscale (tested with accessibility checker)
- [ ] Sufficient contrast between elements (verified)
- [ ] Redundant encoding where appropriate (shapes + colors)
- [ ] Colorblind simulation passes all checks

### Typography and Readability

- [ ] Text minimum 7-8 pt at final size
- [ ] All elements labeled clearly and completely
- [ ] Consistent font family and sizing
- [ ] No text overlaps or cutoffs
- [ ] Units included where applicable

### Publication Standards

- [ ] Consistent styling with other figures in manuscript
- [ ] Comprehensive caption written with all abbreviations defined
- [ ] Referenced appropriately in manuscript text
- [ ] Meets journal-specific dimension requirements
- [ ] Exported in required format for journal (PDF/EPS/TIFF)

### Quality Verification (Required)

- [ ] Ran quality checks and achieved PASS status
- [ ] Reviewed overlap detection report (zero high-severity overlaps)
- [ ] Passed accessibility verification (grayscale and colorblind)
- [ ] Resolution validated at target DPI (300+ for print)
- [ ] Visual quality report generated and reviewed
- [ ] All quality reports saved with figure files

### Documentation and Version Control

- [ ] Source files (.py) saved for future revision
- [ ] Quality reports archived in directory
- [ ] Configuration parameters documented (colors, spacing, sizes)
- [ ] Git commit includes source, output, and quality reports
- [ ] README or comments explain how to regenerate figure

### Final Integration Check

- [ ] Figure displays correctly in compiled manuscript
- [ ] Cross-references work (`\ref{}` points to correct figure)
- [ ] Figure number matches text citations
- [ ] Caption appears on correct page relative to figure
- [ ] No compilation warnings or errors related to figure

## Getting Started

**Simplest possible usage:**

```bash
python scripts/generate_schematic.py "your diagram description" -o output.png
```

---

Use this skill to create clear, accessible, publication-quality diagrams that effectively communicate complex scientific concepts. The AI-powered workflow with iterative refinement ensures diagrams meet professional standards.
