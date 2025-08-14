# Isaac Lab Documentation Index

## 📚 Руководства и документация

### 🚀 Быстрый старт
- **[QUICK_START_DIRECTX.md](QUICK_START_DIRECTX.md)** - Быстрая настройка DirectX для RTX 4090
- **[COMMANDS_REFERENCE.md](COMMANDS_REFERENCE.md)** - Справочник PowerShell команд

### 🔧 Техническая документация  
- **[VULKAN_DIRECTX_TROUBLESHOOTING.md](docs/VULKAN_DIRECTX_TROUBLESHOOTING.md)** - Подробное руководство по решению проблем с графикой

### 📁 Структура проекта

#### Основные директории:
```
IsaacLab/
├── apps/                          # Приложения и kit файлы
│   └── isaacsim_4_5/
│       ├── isaaclab.python.kit           # Оригинальный kit (Vulkan)
│       └── isaaclab.python.directx.kit   # DirectX kit для RTX 4090
├── scripts/                       # Скрипты демонстраций и обучения
│   ├── demos/                     # Демонстрационные скрипты
│   ├── reinforcement_learning/    # Обучение с подкреплением
│   └── tools/                     # Утилиты и инструменты
├── source/                        # Исходный код Isaac Lab
├── logs/                          # Логи обучения
│   └── rsl_rl/                   # Логи RSL-RL
└── docs/                          # Документация
```

#### Важные файлы:
- `isaaclab.bat` - Основной скрипт запуска (Windows)
- `environment.yml` - Conda окружение  
- `pyproject.toml` - Настройки Python проекта

## 🎯 Основные задачи

### 1. Первичная настройка
```powershell
# Активация окружения
conda activate env_isaaclab

# Настройка DirectX для RTX 4090 Laptop
$env:OMNI_KIT_FORCE_GRAPHICS_API = "dx12"
$env:OMNI_KIT_DISABLE_VULKAN = "1"
```

### 2. Обучение роботов
| Робот | Сложность | Время обучения | Recommended envs |
|-------|-----------|---------------|------------------|
| Cartpole | Простая | ~5 минут | 512 |
| Ant | Средняя | ~20 минут | 64 |
| Franka | Средняя | ~30 минут | 32 |
| G1 Humanoid | Сложная | ~1 час | 16 |

### 3. Визуализация результатов
- **TensorBoard**: `tensorboard --logdir logs\rsl_rl --port 6006`
- **Isaac Sim GUI**: Используйте `--experience "...\isaaclab.python.directx.kit"`

## 🛠 Конфигурация оборудования

### Протестированная конфигурация:
- **GPU**: NVIDIA RTX 4090 Laptop GPU (16GB VRAM)
- **Driver**: 576.52
- **CUDA**: 12.9
- **OS**: Windows 11 24H2
- **Python**: 3.10 (conda env_isaaclab)

### Настройки DirectX:
```toml
# В isaaclab.python.directx.kit:
vulkan = false
renderingAPI = "D3D12"
```

## 🎮 Готовые примеры

### Демонстрации (headless mode):
```powershell
# Роботизированные руки
python scripts\demos\arms.py --headless

# Гуманоидные роботы
python scripts\demos\bipeds.py --headless

# Захват объектов
python scripts\demos\pick_and_place.py --headless
```

### Обучение:
```powershell
# Простое обучение (Cartpole)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 512 --max_iterations 200

# Сложное обучение (G1 Humanoid)  
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Humanoid-v0 --num_envs 16 --max_iterations 1500
```

### Воспроизведение обученных моделей:
```powershell
# Использование обученной модели с GUI
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Cartpole-v0 --num_envs 16 --load_run logs\rsl_rl\isaac_cartpole\2025-08-14_08-18-32 --checkpoint model_149.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 🔍 Диагностика проблем

### Основные проблемы и решения:

1. **Черный экран в Isaac Sim**
   - **Причина**: Vulkan не поддерживается
   - **Решение**: Использовать DirectX kit файл

2. **Ошибки VK_EXT_memory_budget**
   - **Причина**: Отсутствует Vulkan расширение
   - **Решение**: Переключение на DirectX 12

3. **Медленное обучение**
   - **Причина**: Слишком много сред для GPU
   - **Решение**: Уменьшить `--num_envs`

### Проверка системы:
```powershell
# GPU статус
nvidia-smi

# Переменные окружения
Get-ChildItem Env: | Where-Object {$_.Name -like "*OMNI*"}

# Доступные задачи
python scripts\tools\list_tasks.py
```

## 📊 Мониторинг и анализ

### TensorBoard метрики:
- **Episode Length**: Длительность эпизодов  
- **Episode Reward**: Награда за эпизод
- **Policy Loss**: Потери политики
- **Value Loss**: Потери функции ценности

### Сохраненные модели:
```
logs/rsl_rl/TASK_NAME/TIMESTAMP/
├── model_*.pt          # Checkpoint модели
├── config.yaml         # Конфигурация обучения
└── events.out.tfevents # TensorBoard логи
```

## 🔗 Полезные ссылки

- [Isaac Lab GitHub](https://github.com/isaac-sim/IsaacLab)
- [NVIDIA Isaac Sim Documentation](https://docs.omniverse.nvidia.com/isaacsim/)
- [RSL-RL Documentation](https://github.com/leggedrobotics/rsl_rl)

## 📋 Контрольный список готовности

- [ ] Conda окружение `env_isaaclab` активировано
- [ ] NVIDIA драйвер 576.52+ установлен  
- [ ] CUDA 12.9+ настроена
- [ ] DirectX kit файл создан
- [ ] Переменные окружения DirectX установлены
- [ ] Isaac Sim запускается без черного экрана
- [ ] TensorBoard доступен на порту 6006

---

**Версия документации**: v1.0  
**Дата создания**: 14 августа 2025  
**Последнее обновление**: 14 августа 2025  
**Протестировано с**: Isaac Lab 0.44.9, Isaac Sim 4.5, RTX 4090 Laptop GPU
