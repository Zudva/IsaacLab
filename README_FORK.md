# Isaac Lab - DirectX Support Fork 🚀

[![Isaac Sim](https://img.shields.io/badge/Isaac%20Sim-4.5-brightgreen.svg)](https://developer.nvidia.com/isaac-sim)
[![Isaac Lab](https://img.shields.io/badge/Isaac%20Lab-0.44.9-blue.svg)](https://github.com/isaac-sim/IsaacLab)
[![DirectX](https://img.shields.io/badge/DirectX-12-red.svg)](https://docs.microsoft.com/en-us/windows/win32/direct3d12/)
[![RTX 4090](https://img.shields.io/badge/RTX%204090-Optimized-green.svg)](https://www.nvidia.com/en-us/geforce/graphics-cards/40-series/rtx-4090/)

Форк Isaac Lab с поддержкой DirectX 12 для RTX 4090 Laptop GPU и решением проблем с Vulkan `VK_EXT_memory_budget`.

## 🎯 Основные улучшения

### ✅ Решенные проблемы:
- **Черный экран в Isaac Sim GUI** на RTX 4090 Laptop GPU
- **Ошибки VK_EXT_memory_budget** при использовании Vulkan
- **Отсутствие русскоязычной документации**
- **Сложность настройки DirectX** для Windows пользователей

### 🚀 Новые возможности:
- **DirectX 12 kit файл** (`isaaclab.python.directx.kit`)
- **Автоматическая настройка** графического API
- **Подробная документация** на русском языке
- **Готовые PowerShell команды** для быстрого старта
- **Оптимизированные настройки** для RTX 4090 Laptop GPU

## 📁 Структура улучшений

```
IsaacLab-DirectX-Fork/
├── apps/isaacsim_4_5/
│   └── isaaclab.python.directx.kit      # DirectX 12 kit файл
├── docs/
│   └── VULKAN_DIRECTX_TROUBLESHOOTING.md # Техническая документация
├── COMMANDS_REFERENCE.md                 # Справочник PowerShell команд
├── QUICK_START_DIRECTX.md               # Быстрый старт с DirectX
├── README_RU.md                         # Русская документация
└── isaac_sim_config.json                # Конфигурация DirectX
```

## 🚀 Быстрый старт

### 1. Клонирование репозитория:
```bash
git clone https://github.com/YOUR_USERNAME/IsaacLab-DirectX-Fork.git
cd IsaacLab-DirectX-Fork
```

### 2. Настройка DirectX (для RTX 4090 Laptop):
```powershell
# Активация conda окружения
conda activate env_isaaclab

# Настройка DirectX
$env:OMNI_KIT_FORCE_GRAPHICS_API = "dx12"
$env:OMNI_KIT_DISABLE_VULKAN = "1"
$env:OMNI_FORCE_GRAPHICS_API = "dx12"
```

### 3. Запуск демонстрации:
```powershell
python scripts\demos\arms.py --experience "apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### 4. Обучение робота:
```powershell
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 512 --max_iterations 200 --experience "apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 📚 Документация

| Документ | Описание |
|----------|----------|
| [QUICK_START_DIRECTX.md](QUICK_START_DIRECTX.md) | Быстрая настройка DirectX |
| [COMMANDS_REFERENCE.md](COMMANDS_REFERENCE.md) | Справочник PowerShell команд |
| [VULKAN_DIRECTX_TROUBLESHOOTING.md](docs/VULKAN_DIRECTX_TROUBLESHOOTING.md) | Техническое руководство |
| [README_RU.md](README_RU.md) | Полная русская документация |

## ⚙️ Протестированная конфигурация

| Компонент | Версия/Модель |
|-----------|---------------|
| **OS** | Windows 11 Home Single Language 24H2 |
| **GPU** | NVIDIA GeForce RTX 4090 Laptop (16GB VRAM) |
| **Driver** | NVIDIA 576.52 |
| **Isaac Sim** | 4.5.0 |
| **Isaac Lab** | 0.44.9 |
| **CUDA** | 12.9 |
| **Python** | 3.10 (conda env_isaaclab) |

## 🎮 Поддерживаемые задачи

### Простые (512+ сред):
- Isaac-Cartpole-v0 (балансировка маятника)
- Isaac-Ant-v0 (четырехногий робот)

### Средние (32-64 среды):
- Isaac-Lift-Franka-v0 (подъем объектов)
- Isaac-Reach-Franka-v0 (достижение цели)

### Сложные (16 сред):
- Isaac-Humanoid-v0 (гуманоидный робот G1)

## 🔍 Диагностика проблем

### Проверка DirectX:
```powershell
# Проверка поддержки DirectX 12
dxdiag

# Проверка NVIDIA драйвера
nvidia-smi

# Проверка переменных окружения
Get-ChildItem Env: | Where-Object {$_.Name -like "*OMNI*"}
```

### Решение типичных проблем:

| Проблема | Решение |
|----------|---------|
| Черный экран в GUI | Использовать `isaaclab.python.directx.kit` |
| VK_EXT_memory_budget ошибка | Настроить переменные DirectX |
| Медленное обучение | Уменьшить `--num_envs` |
| Зависание Isaac Sim | Перезапустить с DirectX kit файлом |

## 🤝 Вклад в проект

1. **Fork** этого репозитория
2. Создайте **feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** ваши изменения (`git commit -m 'Add amazing feature'`)
4. **Push** в branch (`git push origin feature/amazing-feature`)
5. Откройте **Pull Request**

## 📊 Производительность

### Benchmark результаты (RTX 4090 Laptop):

| Задача | Окружений | FPS (DirectX) | FPS (Vulkan) | Улучшение |
|--------|-----------|---------------|--------------|-----------|
| Cartpole | 512 | 60+ | N/A (черный экран) | ∞ |
| Franka | 32 | 45+ | N/A (черный экран) | ∞ |
| Humanoid | 16 | 30+ | N/A (черный экран) | ∞ |

*Vulkan показывает черный экран из-за отсутствия VK_EXT_memory_budget*

## 📄 Лицензия

Этот проект лицензирован под той же лицензией, что и оригинальный Isaac Lab - смотрите файл [LICENSE](LICENSE).

## 🙏 Благодарности

- **NVIDIA Isaac Lab Team** за отличный фреймворк
- **RSL-RL** за алгоритмы обучения с подкреплением
- **Isaac Sim** за мощную платформу симуляции

## 📞 Поддержка

Если у вас есть вопросы или проблемы:
1. Проверьте [документацию](docs/)
2. Посмотрите [Issues](https://github.com/YOUR_USERNAME/IsaacLab-DirectX-Fork/issues)
3. Создайте новый [Issue](https://github.com/YOUR_USERNAME/IsaacLab-DirectX-Fork/issues/new)

---

**🎮 Готов к использованию прямо сейчас! Просто клонируйте и запускайте!** 🚀
