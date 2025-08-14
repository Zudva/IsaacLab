# Isaac Lab - Решение проблем с Vulkan и настройка DirectX

## 🎯 Проблема
RTX 4090 Laptop GPU с драйвером 576.52 не поддерживает расширение Vulkan `VK_EXT_memory_budget`, что приводит к черному экрану в Isaac Sim при использовании GUI режима.

## 🔍 Диагностика проблемы

### Признаки проблемы:
- Черный экран в Isaac Sim GUI
- Ошибки в логах: `VK_EXT_memory_budget is not supported on this platform`
- Предупреждения: `Can't get the VRAM memory usage info`

### Команды для диагностики:
```powershell
# Проверка поддержки Vulkan
python -c "
import vulkan as vk
instance = vk.VkInstance()
devices = vk.vkEnumeratePhysicalDevices(instance)
device = devices[0]
props = vk.vkEnumerateDeviceExtensionProperties(device, None)
extensions = [p.extensionName for p in props]
print('VK_EXT_memory_budget поддерживается:', 'VK_EXT_memory_budget' in extensions)
"

# Проверка драйвера NVIDIA
nvidia-smi

# Проверка версии Isaac Sim
python -c "import omni.isaac.version; print(omni.isaac.version.get_version())"
```

## ✅ Решение: Создание DirectX Kit файла

### Шаг 1: Создание DirectX версии kit файла
```powershell
Copy-Item "apps\isaacsim_4_5\isaaclab.python.kit" "apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Шаг 2: Модификация настроек Vulkan/DirectX
В файле `isaaclab.python.directx.kit` найти строку:
```toml
vulkan = true # Explicitly enable Vulkan (on by default on Linux, off by default on Windows)
```

И заменить на:
```toml
vulkan = false # Force disable Vulkan for DirectX compatibility
renderingAPI = "D3D12" # Force DirectX 12
```

### Шаг 3: Настройка переменных окружения
```powershell
# Создание директории для конфигурации
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\Kit\Isaac-Sim\4.5" -Force

# Настройка переменных окружения
$env:OMNI_CONFIG_DIR = "$env:USERPROFILE\Documents\Kit\Isaac-Sim\4.5"
$env:OMNI_KIT_FORCE_GRAPHICS_API = "dx12"
$env:OMNI_KIT_DISABLE_VULKAN = "1"
$env:OMNI_KIT_DISABLE_VULKAN_VALIDATION = "1"
$env:OMNI_FORCE_GRAPHICS_API = "dx12"
```

### Шаг 4: Создание конфигурационного файла
Создать файл `isaac_sim_config.json`:
```json
{
  "renderer": {
    "graphicsAPI": "dx12",
    "preferDirectX": true,
    "disableVulkan": true
  },
  "display": {
    "enableHeadless": false,
    "forceDirectXMode": true
  },
  "vulkan": {
    "disabled": true,
    "fallbackToDirectX": true
  }
}
```

## 🚀 Использование

### Запуск демонстраций:
```powershell
python scripts\demos\arms.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Запуск обучения:
```powershell
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 64 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Запуск визуализации обученных моделей:
```powershell
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Cartpole-v0 --num_envs 16 --load_run logs\rsl_rl\isaac_cartpole\{timestamp} --checkpoint model_final.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 🔧 Технические детали

### Затронутые файлы:
- `apps\isaacsim_4_5\isaaclab.python.directx.kit` - Новый kit файл с DirectX
- `isaac_sim_config.json` - Конфигурационный файл (опционально)

### Ключевые изменения:
- `vulkan = false` - Отключение Vulkan
- `renderingAPI = "D3D12"` - Принудительное использование DirectX 12
- Переменные окружения для принудительного DirectX

### Проверка успешности:
В логах должно появиться:
```
| Graphics API: D3D12
```
Вместо:
```
| Graphics API: Vulkan
```

## 🐛 Устранение проблем

### Если DirectX все еще не работает:
1. Проверить установку DirectX 12 в системе
2. Обновить драйверы NVIDIA до последней версии
3. Проверить поддержку DirectX 12 видеокартой

### Если окно все еще черное:
1. Убедиться, что используется правильный kit файл
2. Проверить переменные окружения
3. Перезапустить PowerShell после установки переменных

## 📊 Совместимость

### Протестировано на:
- **OS**: Windows 11 Home Single Language 24H2 (Build 26100)
- **GPU**: NVIDIA GeForce RTX 4090 Laptop (16GB VRAM)
- **Driver**: NVIDIA 576.52
- **Isaac Sim**: 4.5.0
- **Isaac Lab**: 0.44.9
- **CUDA**: 12.9

### Известные ограничения:
- Решение специфично для систем без поддержки `VK_EXT_memory_budget`
- Может потребовать адаптация для других версий Isaac Sim
- Производительность DirectX может отличаться от Vulkan

## 📝 Примечания
- Всегда используйте DirectX kit файл для GUI режима
- Headless режим может работать с обычным kit файлом
- Сохраните оригинальный kit файл как резервную копию
