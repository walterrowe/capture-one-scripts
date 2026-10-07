# Auto Keyword

**Donations**: If you like to keep these scripts free, please consider [buying me a coffee](https://buymeacoffee.com/walterrowe).

## DISCLAIMER

This script was developed with assistance from Google Gemini to interface with Apple's Native Vision Framework APIs via AppleScript Objective-C (ASObjC).

## PRIVACY STATEMENT

* **LOCAL PROCESSING** - Your images NEVER leave your machine.
* **DATA SECURITY** - Your images are not used to train Apple's models.

See [Apple's AI & Privacy Statement](https://www.apple.com/legal/ai-regulations/training-data/) on Apple's website.

## Description

This script leverages Apple's native Vision machine learning model to automatically classify content, detect human subjects and poses, recognize text (OCR), parse barcodes, and evaluate image aesthetics for selected images in Capture One.

### Key Capabilities

- **Multi-Request Vision ML Processing**:
  - **Classification**: Generates content labels filtered at a $\ge 20\%$ confidence threshold.
  - **Animal Recognition**: Detects animals and assigns capitalized identifiers.
  - **Human Subject & Pose Detection**: Categorizes images as *Portrait*, *Person*, *People*, or *Group Photo*, and analyzes keypoint joint positions to flag *Action* shots.
  - **Text Recognition (Fast OCR)**: Extracts high-confidence text fragments directly from images.
  - **Barcode / QR Code Parsing**: Extracts payload values and sanitizes strings into usable tags.
  - **Horizon & Tilt Detection**: Measures horizon angles and identifies images with a $> 2.5^\circ$ tilt (*Tilted Horizon*).
  - **Aesthetics & Exposure Evaluation**: Evaluates overall aesthetic scores ($> 0.6$ assigned *High Quality*) and flags *Underexposed* or *Overexposed* frames.
- **Smart Vocabulary & Hierarchy Matching**:
  - Matches returned Vision tags against the open Capture One document's existing vocabulary.
  - Prioritizes hierarchical leaf keywords over root/flat keywords (e.g., if both `Sport` and `Sport|Baseball` exist, `Sport|Baseball` is applied).
  - Handles singular/plural variations automatically before adding new keywords.
- **Performance & Progress Integration**:
  - Uses native Capture One progress updates and macOS system status.
  - Limits keyword application to a configurable maximum (default: 50 keywords per image).

## Prerequisites

- macOS 15 (Sequoia) or later
- Capture One 16.8 or later

## Installation

The script self-installs into your local Capture One Scripts folder on first run.

1. Open `Auto Keyword.applescript` (or `.scpt`) in macOS **Script Editor**.
2. Click the **Run** button (&#9654;). The script will automatically download and compile the required `COscriptlibrary` library into `~/Library/Scripts/Capture One Scripts/`.
3. Open Capture One and navigate to **Scripts > Update Script Menu**.
4. You can now execute **Auto Keyword** directly from Capture One's **Scripts** menu.

## How To Use

1. Select one or more images or variants in your Capture One catalog or session.
2. Open the **Scripts** menu and select **Auto Keyword**.
3. Progress is displayed in real-time in the macOS menu bar / Capture One progress bar.
4. Upon completion, a confirmation dialog summarizes the elapsed time and total images keyworded.

## Compatibility

Tested and validated on:

- macOS 26 (Tahoe) / macOS 27 (Golden Gate)
- Capture One 16.8+ (should work on prior versions of Capture One)

## ChangeLog

- **06 Oct 2026** - Initial release with multi-request Vision ML integration, hierarchical keyword leaf resolution, OCR, barcode detection, and aesthetic analysis.
