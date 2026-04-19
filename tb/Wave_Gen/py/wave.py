import matplotlib.pyplot as plt

WAVE_FILE = 'D:/VivadoProjects/WaveOscillation/project_1/out/wave.dat'
SAMPLES_READ = 6400
SAMPLE_BITS = 8

data = list()

with open(WAVE_FILE, 'rb') as f:
    for i in range(SAMPLES_READ):
        data.append(int.from_bytes(f.read(SAMPLE_BITS >> 3)))

plt.plot(list(range(SAMPLES_READ)), data, color='green', linestyle='-', marker='o')

plt.title("Wave")
plt.xlabel("Sample")
plt.ylabel("Amplitude")

plt.show()