import math

MEM_FILE = "./lut.mif"
LUT_BYTES = 32
SAMPLE_BYTES = 1
MAX_SAMPLE = 128

with open(MEM_FILE, 'w') as f:
    for i in range(1, LUT_BYTES + 1):
        v = int((1 + math.sin(2 * math.pi * i / LUT_BYTES)) / 2 * MAX_SAMPLE)
        f.write(f"{v:0{SAMPLE_BYTES * 2}x}\n")

    print(f'Hex lut file generated ({SAMPLE_BYTES} bytes * {LUT_BYTES} dots).')