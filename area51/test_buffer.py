# test_buffer.py
import sys
import time

for i in range(5):
    print(f"Step {i}", end="", flush=False)  # No newline, no manual flush
    sys.stdout.write(".")  # Add dots without newline
    time.sleep(1)

print("\nDone!")