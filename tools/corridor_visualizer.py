#!/usr/bin/env python3
"""Interactive terminal visualization for transmission line corridor catenary profiles."""

import sys
import math

def render_corridor_ascii(spans=5, span_length=300.0, base_sag=7.2, clearance=27.8):
    print("=" * 79)
    print("  SAGITTA :: High-Voltage Transmission Corridor Catenary & Clearance Profile")
    print("=" * 79)
    print(f"Spans: {spans} | Span Length: {span_length} m | Max Midspan Sagitta: {base_sag:.2f} m")
    print(f"Minimum Statutory Ground Clearance: 7.50 m | Nominal Clearance: {clearance:.2f} m\n")

    # Tower height: 35 m; ground at 0 m
    rows = 15
    cols = 75
    grid = [[" " for _ in range(cols)] for _ in range(rows)]

    # Draw towers
    tower_positions = [int(i * (cols - 1) / spans) for i in range(spans + 1)]
    for tp in tower_positions:
        for r in range(rows):
            grid[r][tp] = "|"
        grid[0][tp] = "T"
        grid[rows - 1][tp] = "#"

    # Draw catenary curve across spans
    for c in range(cols):
        # Determine span index
        span_idx = int(c * spans / cols)
        c_left = int(span_idx * cols / spans)
        c_right = int((span_idx + 1) * cols / spans)
        span_w = max(1, c_right - c_left)

        x_norm = (c - c_left) / float(span_w)
        # Parabolic sag: y_drop = 4 * sag * x * (1 - x)
        y_drop = 4.0 * base_sag * x_norm * (1.0 - x_norm)
        elev = 35.0 - y_drop
        # Map elevation (0 to 35) to row (rows - 1 to 0)
        r = int((35.0 - elev) / 35.0 * (rows - 2))
        if 0 <= r < rows:
            if grid[r][c] == " ":
                grid[r][c] = "."

    # Draw statutory ground clearance limit (7.5 m)
    r_statutory = int((35.0 - 7.5) / 35.0 * (rows - 2))
    for c in range(cols):
        if grid[r_statutory][c] == " ":
            grid[r_statutory][c] = "_"

    for r in range(rows):
        line = "".join(grid[r])
        elev_label = 35.0 - (r / float(rows - 1)) * 35.0
        print(f"{elev_label:4.1f}m {line}")

    print(" " * 6 + "=" * cols)
    print(" " * 6 + "0m" + " " * 30 + f"{span_length * spans / 2:.0f}m" + " " * 28 + f"{span_length * spans:.0f}m")
    print("\nLegend: 'T' Tower Attachment | '.' Conductor Catenary | '_' 7.5m Statutory Limit | '#' Ground")
    print("=" * 79)

def main():
    spans = 4
    if len(sys.argv) > 1:
      try:
        spans = int(sys.argv[1])
      except ValueError:
        pass
    render_corridor_ascii(spans=spans)

if __name__ == "__main__":
    main()
