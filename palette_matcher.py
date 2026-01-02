#!/usr/bin/env python3
"""
Palette Matcher - Batch sprite recoloring tool

Replicates the Paint.NET workflow:
1. Quantize to N colors (no dithering)
2. Map to custom palette (nearest color match)

Supports Paint.NET palette format (.txt) from Lospec and Paint.NET itself.
"""

import argparse
import sys
import os
from pathlib import Path
from typing import List, Tuple
import math

# Auto-install dependencies if needed
try:
    from PIL import Image
    import numpy as np
except ImportError:
    import subprocess
    print("Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "numpy", "-q", "--break-system-packages"])
    from PIL import Image
    import numpy as np


# =============================================================================
# CIEDE2000 Color Distance Implementation
# =============================================================================
# This is the most perceptually accurate color distance formula, matching
# how humans actually perceive color differences.

def rgb_to_lab(rgb: np.ndarray) -> np.ndarray:
    """Convert RGB (0-255) to CIELAB color space."""
    # Normalize RGB to 0-1
    rgb_norm = rgb / 255.0
    
    # sRGB to linear RGB
    mask = rgb_norm > 0.04045
    rgb_linear = np.where(mask, ((rgb_norm + 0.055) / 1.055) ** 2.4, rgb_norm / 12.92)
    
    # Linear RGB to XYZ (D65 illuminant)
    # Using matrix multiplication for the conversion
    r, g, b = rgb_linear[..., 0], rgb_linear[..., 1], rgb_linear[..., 2]
    x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
    y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
    z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
    
    # XYZ to Lab (D65 reference white)
    x_ref, y_ref, z_ref = 0.95047, 1.0, 1.08883
    x = x / x_ref
    y = y / y_ref
    z = z / z_ref
    
    epsilon = 0.008856
    kappa = 903.3
    
    fx = np.where(x > epsilon, np.cbrt(x), (kappa * x + 16) / 116)
    fy = np.where(y > epsilon, np.cbrt(y), (kappa * y + 16) / 116)
    fz = np.where(z > epsilon, np.cbrt(z), (kappa * z + 16) / 116)
    
    L = 116 * fy - 16
    a = 500 * (fx - fy)
    b_val = 200 * (fy - fz)
    
    return np.stack([L, a, b_val], axis=-1)


def ciede2000_distance(lab1: np.ndarray, lab2: np.ndarray) -> np.ndarray:
    """
    Calculate CIEDE2000 color difference.
    
    lab1: shape (N, 3) or (3,) - first color(s) in Lab
    lab2: shape (M, 3) or (3,) - second color(s) in Lab
    
    Returns: distance(s) between colors
    """
    # Ensure proper shapes for broadcasting
    if lab1.ndim == 1:
        lab1 = lab1.reshape(1, 3)
    if lab2.ndim == 1:
        lab2 = lab2.reshape(1, 3)
    
    L1, a1, b1 = lab1[..., 0], lab1[..., 1], lab1[..., 2]
    L2, a2, b2 = lab2[..., 0], lab2[..., 1], lab2[..., 2]
    
    # Calculate C and h
    C1 = np.sqrt(a1**2 + b1**2)
    C2 = np.sqrt(a2**2 + b2**2)
    
    C_avg = (C1 + C2) / 2
    C_avg_7 = C_avg**7
    G = 0.5 * (1 - np.sqrt(C_avg_7 / (C_avg_7 + 25**7)))
    
    a1_prime = a1 * (1 + G)
    a2_prime = a2 * (1 + G)
    
    C1_prime = np.sqrt(a1_prime**2 + b1**2)
    C2_prime = np.sqrt(a2_prime**2 + b2**2)
    
    h1_prime = np.degrees(np.arctan2(b1, a1_prime)) % 360
    h2_prime = np.degrees(np.arctan2(b2, a2_prime)) % 360
    
    # Calculate deltas
    dL_prime = L2 - L1
    dC_prime = C2_prime - C1_prime
    
    h_diff = h2_prime - h1_prime
    dh_prime = np.where(
        C1_prime * C2_prime == 0, 0,
        np.where(np.abs(h_diff) <= 180, h_diff,
                 np.where(h_diff > 180, h_diff - 360, h_diff + 360))
    )
    dH_prime = 2 * np.sqrt(C1_prime * C2_prime) * np.sin(np.radians(dh_prime / 2))
    
    # Calculate averages
    L_avg = (L1 + L2) / 2
    C_avg_prime = (C1_prime + C2_prime) / 2
    
    h_sum = h1_prime + h2_prime
    h_avg_prime = np.where(
        C1_prime * C2_prime == 0, h_sum,
        np.where(np.abs(h_diff) <= 180, h_sum / 2,
                 np.where(h_sum < 360, (h_sum + 360) / 2, (h_sum - 360) / 2))
    )
    
    # Calculate T
    T = (1 - 0.17 * np.cos(np.radians(h_avg_prime - 30))
         + 0.24 * np.cos(np.radians(2 * h_avg_prime))
         + 0.32 * np.cos(np.radians(3 * h_avg_prime + 6))
         - 0.20 * np.cos(np.radians(4 * h_avg_prime - 63)))
    
    # Calculate weighting functions
    L_avg_minus_50_sq = (L_avg - 50)**2
    S_L = 1 + (0.015 * L_avg_minus_50_sq) / np.sqrt(20 + L_avg_minus_50_sq)
    S_C = 1 + 0.045 * C_avg_prime
    S_H = 1 + 0.015 * C_avg_prime * T
    
    # Calculate R_T
    C_avg_prime_7 = C_avg_prime**7
    R_C = 2 * np.sqrt(C_avg_prime_7 / (C_avg_prime_7 + 25**7))
    delta_theta = 30 * np.exp(-((h_avg_prime - 275) / 25)**2)
    R_T = -np.sin(np.radians(2 * delta_theta)) * R_C
    
    # Final calculation (kL = kC = kH = 1 for standard conditions)
    dE = np.sqrt(
        (dL_prime / S_L)**2 +
        (dC_prime / S_C)**2 +
        (dH_prime / S_H)**2 +
        R_T * (dC_prime / S_C) * (dH_prime / S_H)
    )
    
    return dE


def load_palette(path: str) -> np.ndarray:
    """
    Load a palette file. Supports:
    - Paint.NET format: AARRGGBB or RRGGBB hex
    - Lospec format: Same as Paint.NET
    - Simple hex: #RRGGBB or RRGGBB, one per line
    """
    colors = []
    
    with open(path) as f:
        for line in f:
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith(';') or line.startswith('//'):
                continue
            
            # Remove # prefix if present
            if line.startswith('#'):
                line = line[1:]
            
            # Remove 0x prefix if present
            if line.lower().startswith('0x'):
                line = line[2:]
            
            try:
                if len(line) == 8:  # AARRGGBB format
                    r = int(line[2:4], 16)
                    g = int(line[4:6], 16)
                    b = int(line[6:8], 16)
                    colors.append([r, g, b])
                elif len(line) == 6:  # RRGGBB format
                    r = int(line[0:2], 16)
                    g = int(line[2:4], 16)
                    b = int(line[4:6], 16)
                    colors.append([r, g, b])
                elif len(line) == 3:  # RGB shorthand
                    r = int(line[0] * 2, 16)
                    g = int(line[1] * 2, 16)
                    b = int(line[2] * 2, 16)
                    colors.append([r, g, b])
            except ValueError:
                continue
    
    if not colors:
        raise ValueError(f"No valid colors found in {path}")
    
    return np.array(colors, dtype=np.float32)


def quantize_no_dither(img: Image.Image, n_colors: int) -> Image.Image:
    """Quantize image to N colors without dithering."""
    has_alpha = img.mode == 'RGBA'
    
    if has_alpha:
        alpha = img.split()[3]
        rgb = img.convert('RGB')
    else:
        rgb = img.convert('RGB')
    
    # Quantize without dithering
    quantized = rgb.quantize(colors=n_colors, method=Image.Quantize.MEDIANCUT, dither=0)
    result = quantized.convert('RGB')
    
    if has_alpha:
        result = result.convert('RGBA')
        result.putalpha(alpha)
    
    return result


def apply_palette(img: Image.Image, palette: np.ndarray, 
                  distance: str = 'euclidean',
                  weights: Tuple[float, float, float] = (1.0, 1.0, 1.0)) -> Image.Image:
    """
    Map image colors to nearest palette colors.
    
    Distance methods:
    - euclidean: Standard RGB distance
    - weighted: Weighted RGB distance (default weights approximate human perception)
    - manhattan: Sum of absolute differences
    - ciede2000: Perceptually uniform color distance (most accurate, slower)
    """
    has_alpha = img.mode == 'RGBA'
    
    if has_alpha:
        alpha = np.array(img.split()[3])
        pixels = np.array(img.convert('RGB'), dtype=np.float32)
    else:
        pixels = np.array(img.convert('RGB'), dtype=np.float32)
    
    h, w, _ = pixels.shape
    flat = pixels.reshape(-1, 3)
    
    # Get unique colors first for efficiency (major speedup for sprites with limited colors)
    flat_uint8 = flat.astype(np.uint8)
    unique_colors, inverse_idx = np.unique(
        flat_uint8.view(np.dtype((np.void, 3))), 
        return_inverse=True
    )
    unique_colors = unique_colors.view(np.uint8).reshape(-1, 3).astype(np.float32)
    
    if distance == 'ciede2000':
        # CIEDE2000: Convert to Lab and use perceptual distance
        unique_lab = rgb_to_lab(unique_colors)
        palette_lab = rgb_to_lab(palette)
        
        # Calculate CIEDE2000 distances for each unique color to each palette color
        nearest_indices = np.zeros(len(unique_colors), dtype=np.int32)
        
        for i, lab in enumerate(unique_lab):
            dists = ciede2000_distance(lab.reshape(1, 3), palette_lab)
            nearest_indices[i] = np.argmin(dists)
    else:
        # RGB-based distance methods (euclidean, manhattan, weighted)
        w_arr = np.array(weights, dtype=np.float32)
        
        if distance == 'manhattan':
            diffs = np.abs(unique_colors[:, np.newaxis, :] - palette[np.newaxis, :, :])
            dists = (diffs * w_arr).sum(axis=2)
        else:
            # Euclidean (or weighted euclidean)
            diffs = unique_colors[:, np.newaxis, :] - palette[np.newaxis, :, :]
            dists = np.sqrt(((diffs ** 2) * w_arr).sum(axis=2))
        
        nearest_indices = np.argmin(dists, axis=1)
    
    # Map back to all pixels using the inverse index
    result_flat = palette[nearest_indices[inverse_idx]]
    result = result_flat.reshape(h, w, 3).astype(np.uint8)
    
    # Create output image
    out = Image.fromarray(result, 'RGB')
    if has_alpha:
        out = out.convert('RGBA')
        out.putalpha(Image.fromarray(alpha))
    
    return out


def process_image(input_path: str, output_path: str, palette: np.ndarray,
                  quantize_colors: int = 64, distance: str = 'euclidean',
                  weights: Tuple[float, float, float] = (1.0, 1.0, 1.0),
                  skip_quantize: bool = False) -> bool:
    """Process a single image through the pipeline."""
    try:
        img = Image.open(input_path)
        
        # Step 1: Quantize (optional)
        if not skip_quantize and quantize_colors > 0:
            img = quantize_no_dither(img, quantize_colors)
        
        # Step 2: Apply palette
        result = apply_palette(img, palette, distance, weights)
        
        # Save result
        result.save(output_path)
        return True
        
    except Exception as e:
        print(f"    Error: {e}")
        return False


def batch_process(input_dir: str, output_dir: str, palette: np.ndarray,
                  quantize_colors: int = 64, distance: str = 'euclidean',
                  weights: Tuple[float, float, float] = (1.0, 1.0, 1.0),
                  skip_quantize: bool = False, recursive: bool = False,
                  extensions: tuple = ('.png', '.jpg', '.jpeg', '.bmp', '.gif', '.webp')) -> Tuple[int, int]:
    """Process all images in a directory."""
    
    in_path = Path(input_dir)
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)
    
    # Find images
    if recursive:
        files = [f for f in in_path.rglob('*') if f.suffix.lower() in extensions]
    else:
        files = [f for f in in_path.iterdir() if f.is_file() and f.suffix.lower() in extensions]
    
    files = sorted(files)
    total = len(files)
    
    if total == 0:
        print(f"No images found in {input_dir}")
        return 0, 0
    
    print(f"\nProcessing {total} images...")
    if not skip_quantize:
        print(f"  Quantize: {quantize_colors} colors")
    print(f"  Distance: {distance}")
    if weights != (1.0, 1.0, 1.0):
        print(f"  Weights: R={weights[0]}, G={weights[1]}, B={weights[2]}")
    print()
    
    success = 0
    failed = 0
    
    for i, f in enumerate(files, 1):
        # Preserve folder structure
        rel = f.relative_to(in_path)
        out_file = out_path / rel
        out_file.parent.mkdir(parents=True, exist_ok=True)
        
        print(f"[{i:3d}/{total}] {rel}...", end=' ', flush=True)
        
        if process_image(str(f), str(out_file), palette, quantize_colors, 
                         distance, weights, skip_quantize):
            print("✓")
            success += 1
        else:
            print("✗")
            failed += 1
    
    return success, failed


def create_sample_palette(output_path: str):
    """Create a sample palette file."""
    sample = """;paint.net Palette File
;Sample 16-color palette (PICO-8)
;Format: AARRGGBB
FF000000
FF1D2B53
FF7E2553
FF008751
FFAB5236
FF5F574F
FFC2C3C7
FFFFFFFF
FFFF004D
FFFFA300
FFFFEC27
FF00E436
FF29ADFF
FF83769C
FFFF77A8
FFFFCCAA
"""
    with open(output_path, 'w') as f:
        f.write(sample)
    print(f"Created sample palette: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        prog='palette_matcher',
        description='Batch sprite recoloring tool - quantize and map to custom palette',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage - process folder of sprites (quantizes to 128 colors by default)
  python palette_matcher.py -i ./sprites -o ./output -p palette.txt

  # Use perceptual color matching (CIEDE2000 - most accurate)
  python palette_matcher.py -i ./sprites -o ./output -p palette.txt --perceptual

  # Skip quantization (palette mapping only)
  python palette_matcher.py -i ./sprites -o ./output -p palette.txt --skip-quantize

  # Different quantization level (e.g., 64 or 256)
  python palette_matcher.py -i ./sprites -o ./output -p palette.txt -c 64

  # Process subfolders recursively
  python palette_matcher.py -i ./sprites -o ./output -p palette.txt -r

  # Process single image
  python palette_matcher.py -i sprite.png -o recolored.png -p palette.txt

  # Create a sample palette file
  python palette_matcher.py --create-sample sample_palette.txt

Distance Methods:
  euclidean   Standard RGB distance (fast, good default)
  manhattan   Sum of absolute RGB differences (fast)
  weighted    Weighted RGB with custom weights
  ciede2000   Perceptually uniform distance (most accurate, slower)
              Use --perceptual as shortcut for -d ciede2000

Palette Format:
  Supports Paint.NET / Lospec .txt format:
  - Lines starting with ; are comments
  - Colors as AARRGGBB or RRGGBB hex values
  - Download directly from lospec.com with "Paint.net TXT" option

Workflow:
  This replicates the Paint.NET workflow of:
  1. Adjustments > Quantize (colors=64, dithering=0)
  2. Effects > Color > TR's Custom Palette Matcher
        """)
    
    # Input/Output
    parser.add_argument('-i', '--input', metavar='PATH',
                        help='Input image or folder')
    parser.add_argument('-o', '--output', metavar='PATH',
                        help='Output image or folder')
    parser.add_argument('-p', '--palette', metavar='FILE',
                        help='Palette file (.txt)')
    
    # Processing options
    parser.add_argument('-c', '--colors', type=int, default=128, metavar='N',
                        help='Quantize to N colors before palette mapping (default: 128)')
    parser.add_argument('--skip-quantize', action='store_true',
                        help='Skip quantization, only apply palette mapping')
    parser.add_argument('-r', '--recursive', action='store_true',
                        help='Process subfolders recursively')
    
    # Distance options
    parser.add_argument('-d', '--distance', choices=['euclidean', 'manhattan', 'weighted', 'ciede2000'],
                        default='euclidean', metavar='METHOD',
                        help='Color distance method: euclidean, manhattan, weighted, ciede2000 (default: euclidean)')
    parser.add_argument('--perceptual', action='store_true',
                        help='Use CIEDE2000 perceptual color distance (most accurate, slower). Same as -d ciede2000')
    parser.add_argument('--weights', type=float, nargs=3, default=[1.0, 1.0, 1.0],
                        metavar=('R', 'G', 'B'),
                        help='RGB weights for distance calculation (default: 1.0 1.0 1.0, '
                             'perceptual: 0.3 0.59 0.11)')
    
    # Utility
    parser.add_argument('--create-sample', metavar='FILE',
                        help='Create a sample palette file and exit')
    parser.add_argument('--list-colors', metavar='FILE',
                        help='List colors in a palette file and exit')
    
    args = parser.parse_args()
    
    # Handle utility commands
    if args.create_sample:
        create_sample_palette(args.create_sample)
        return
    
    if args.list_colors:
        try:
            palette = load_palette(args.list_colors)
            print(f"Palette: {args.list_colors}")
            print(f"Colors: {len(palette)}\n")
            for i, (r, g, b) in enumerate(palette):
                print(f"  {i+1:3d}. #{int(r):02X}{int(g):02X}{int(b):02X}")
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)
        return
    
    # Validate required arguments
    if not args.input:
        parser.error("--input is required (use --help for usage)")
    if not args.palette:
        parser.error("--palette is required (use --help for usage)")
    if not args.output:
        parser.error("--output is required (use --help for usage)")
    
    # Load palette
    try:
        palette = load_palette(args.palette)
        print(f"✓ Loaded palette: {len(palette)} colors")
    except Exception as e:
        print(f"Error loading palette: {e}")
        sys.exit(1)
    
    # Handle --perceptual flag (shortcut for -d ciede2000)
    if args.perceptual:
        args.distance = 'ciede2000'
    
    # Convert weights tuple
    weights = tuple(args.weights)
    
    # Check if input is file or directory
    input_path = Path(args.input)
    
    if input_path.is_file():
        # Single file mode
        print(f"Processing: {args.input}")
        if process_image(args.input, args.output, palette, args.colors,
                         args.distance, weights, args.skip_quantize):
            print(f"✓ Saved: {args.output}")
        else:
            print("✗ Failed")
            sys.exit(1)
    
    elif input_path.is_dir():
        # Batch mode
        success, failed = batch_process(
            args.input, args.output, palette,
            args.colors, args.distance, weights,
            args.skip_quantize, args.recursive
        )
        
        print(f"\n{'─' * 40}")
        print(f"Complete: {success} succeeded, {failed} failed")
        print(f"Output: {args.output}")
        
        if failed > 0:
            sys.exit(1)
    
    else:
        print(f"Error: {args.input} not found")
        sys.exit(1)


if __name__ == '__main__':
    main()