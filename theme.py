#!/usr/bin/env python3

from PIL import Image
import numpy as np

def average_color_hex(image_path):
    try:
        # Open the image and convert to RGB
        img = Image.open(image_path).convert('RGB')
        
        # Convert image to numpy array
        np_img = np.array(img)

        # Compute the mean color
        avg_color = np_img.mean(axis=(0, 1)).astype(int)

        # Convert to hex string
        hex_color = '#{:02x}{:02x}{:02x}'.format(*avg_color)

        return hex_color

    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python average_color_hex.py <image_path>")
    else:
        image_path = sys.argv[1]
        hex_color = average_color_hex(image_path)
        if hex_color:
            print(f"Average color (hex): {hex_color}")

