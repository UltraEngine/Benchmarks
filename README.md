# Ultra Engine Benchmarks

Performance benchmarks comparing Ultra Engine, Leadwerks, and Unity.

## Diagnostic Tools

[FRAPS](https://www.fraps.com) can be used to measure the framerate. Some other FPS counter overlays will reduce performance significantly enough to alter your readings, by a lot.

[TechPowerUp GPU-Z](https://www.techpowerup.com/download/gpu-z/) can be used to measure GPU utilization. Windows task manager does not provide a correct measure of this metric.

## Results

All measurements were recorded using a PC with a quad-core Intel Core i7-7700K CPU @4.20 GHz and an Nvidia GeForce 1080 GTX GPU with driver 471.41 installed, on Windows 10.

### Instanced Geometry Test

| Engine | GPU Utilization | Framerate |
|--|--|--|
| Leadwerks (OpenGL) | 8% | 52 |
| Unity (DX11) | 4% | 40 |
| Unity (Vulkan) | 4% | 40 |
| Ultra Engine (Vulkan) | 95% | 1206 |

### Animation Test

| Engine | GPU Utilization | Framerate |
|--|--|--|
| Leadwerks (OpenGL) | 1% | 5 |
| Unity (DX11) | 45% | 62 |
| Unity (Vulkan) | 45% | 64 |
| Ultra Engine (Vulkan) | 96% | 1179 |

### Lighting Test

| Engine | GPU Utilization | Framerate |
|--|--|--|
| Leadwerks (OpenGL) | 49% | 704 |
| Unity (DX11) | 33% | 90 |
| Unity (Vulkan) | 30% | 74 |
| Ultra Engine (Vulkan) | 96% | 1456 |

### Unique Geometry Test

| Engine | GPU Utilization | Framerate |
|--|--|--|
| Leadwerks (OpenGL) | 10% | 49 |
| Unity (DX11) | 5% | 2 |
| Unity (Vulkan) | 4% | 2 |
| Ultra Engine (Vulkan) | 63% | 6213 |
