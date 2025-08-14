# Isaac Lab PowerShell Commands Reference

## 🚀 Настройка окружения

### Активация conda среды:
```powershell
conda activate env_isaaclab
```

### Быстрая настройка DirectX (для RTX 4090 Laptop):
```powershell
$env:OMNI_KIT_FORCE_GRAPHICS_API = "dx12"
$env:OMNI_KIT_DISABLE_VULKAN = "1" 
$env:OMNI_FORCE_GRAPHICS_API = "dx12"
```

## 🎮 Демонстрации

```powershell
# Роботизированные руки
python scripts\demos\arms.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Четырехногие роботы  
python scripts\demos\quadrupeds.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Двуногие роботы
python scripts\demos\bipeds.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Захват и размещение объектов
python scripts\demos\pick_and_place.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Множественные ассеты
python scripts\demos\multi_asset.py --num_envs 4 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 🧠 Обучение с подкреплением (RSL-RL)

### Простые задачи:
```powershell
# Cartpole (балансировка маятника)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 512 --max_iterations 1000 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Ant (четырехногий робот)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Ant-v0 --num_envs 64 --max_iterations 2000 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Манипуляторы:
```powershell
# Franka - подъем объектов
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Lift-Franka-v0 --num_envs 32 --max_iterations 1500 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Franka - достижение цели
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Reach-Franka-v0 --num_envs 64 --max_iterations 1000 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Гуманоидные роботы:
```powershell
# G1 Humanoid (сложная задача)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Humanoid-v0 --num_envs 16 --max_iterations 2000 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 🎯 Воспроизведение обученных моделей

```powershell
# Общий шаблон
python scripts\reinforcement_learning\rsl_rl\play.py --task TASK_NAME --num_envs 16 --load_run logs\rsl_rl\TASK_FOLDER\TIMESTAMP --checkpoint model_final.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Примеры:
# Cartpole
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Cartpole-v0 --num_envs 16 --load_run logs\rsl_rl\isaac_cartpole\2025-08-14_08-18-32 --checkpoint model_149.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Franka
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Lift-Franka-v0 --num_envs 8 --load_run logs\rsl_rl\isaac_lift_franka\2025-08-14_08-45-15 --checkpoint model_999.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# G1 Humanoid  
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Humanoid-v0 --num_envs 4 --load_run logs\rsl_rl\isaac_humanoid\2025-08-14_09-19-01 --checkpoint model_1499.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 📊 Мониторинг и анализ

### TensorBoard:
```powershell
# Запуск TensorBoard для всех экспериментов
tensorboard --logdir logs\rsl_rl --port 6006

# Для конкретной задачи
tensorboard --logdir logs\rsl_rl\isaac_cartpole --port 6006
```

### Просмотр структуры логов:
```powershell
# Список всех экспериментов
Get-ChildItem logs\rsl_rl -Directory

# Содержимое конкретного эксперимента
Get-ChildItem "logs\rsl_rl\isaac_cartpole\2025-08-14_08-18-32"
```

## 🔍 Диагностика и отладка

### Проверка конфигурации:
```powershell
# Проверка переменных окружения
Get-ChildItem Env: | Where-Object {$_.Name -like "*OMNI*"}

# Проверка NVIDIA драйвера
nvidia-smi

# Проверка CUDA
nvcc --version
```

### Проверка Isaac Lab:
```powershell
# Список доступных задач
python scripts\tools\list_tasks.py

# Проверка конкретной задачи
python scripts\tools\check_env.py --task Isaac-Cartpole-v0
```

### Очистка и сброс:
```powershell
# Очистка кэша
Remove-Item -Recurse -Force "$env:TEMP\omniverse"

# Перезапуск с чистой конфигурацией  
$env:OMNI_CONFIG_DIR = ""
```

## ⚙️ Настройка производительности

### Оптимизация для RTX 4090:
```powershell
# Больше сред для простых задач
--num_envs 512  # Cartpole

# Меньше сред для сложных задач  
--num_envs 16   # Humanoid

# Настройка GPU памяти
$env:CUDA_VISIBLE_DEVICES = "0"
```

### Параметры обучения:
```powershell
# Быстрое обучение (тестирование)
--max_iterations 100

# Полное обучение  
--max_iterations 2000

# Сохранение каждые N итераций
--save_interval 100
```

## 🛠 Создание DirectX kit файла

```powershell
# 1. Копирование оригинального файла
Copy-Item "apps\isaacsim_4_5\isaaclab.python.kit" "apps\isaacsim_4_5\isaaclab.python.directx.kit"

# 2. Ручное редактирование (заменить в файле):
# vulkan = true  →  vulkan = false
# Добавить: renderingAPI = "D3D12"
```

## 📝 Полезные команды Windows

```powershell
# Мониторинг GPU
nvidia-smi -l 1

# Мониторинг процессов
Get-Process | Where-Object {$_.ProcessName -like "*python*"}

# Убить зависшие процессы Isaac Sim
Get-Process | Where-Object {$_.ProcessName -like "*isaac*"} | Stop-Process -Force

# Проверка использования порта TensorBoard
netstat -an | findstr :6006
```
