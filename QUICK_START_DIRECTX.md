# Isaac Lab - Быстрый старт с DirectX

## 🎯 Для решения проблемы черного экрана

Если у вас черный экран в Isaac Sim - используйте эти команды:

### 1. Одной командой - настройка переменных окружения:
```powershell
$env:OMNI_KIT_FORCE_GRAPHICS_API = "dx12"; $env:OMNI_KIT_DISABLE_VULKAN = "1"; $env:OMNI_FORCE_GRAPHICS_API = "dx12"
```

### 2. Запуск с DirectX kit файлом:
```powershell
# Демонстрации
python scripts\demos\arms.py --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Обучение Cartpole
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 64 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Обучение Humanoid (G1)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Humanoid-v0 --num_envs 32 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### 3. Проверка - в логах должно быть:
```
| Graphics API: D3D12
```

## 🚀 Готовые команды для обучения

### Простые среды:
```powershell
# Cartpole (маятник)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Cartpole-v0 --num_envs 512 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# Ant (четырехногий робот)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Ant-v0 --num_envs 64 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

### Сложные роботы:
```powershell
# Franka (манипулятор)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Lift-Franka-v0 --num_envs 32 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"

# G1 Humanoid (гуманоид)
python scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Humanoid-v0 --num_envs 16 --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 📊 Мониторинг обучения

### TensorBoard:
```powershell
tensorboard --logdir logs\rsl_rl
```

### Просмотр результатов:
```powershell
# Замените {timestamp} на реальную папку из logs\rsl_rl\isaac_cartpole\
python scripts\reinforcement_learning\rsl_rl\play.py --task Isaac-Cartpole-v0 --num_envs 16 --load_run logs\rsl_rl\isaac_cartpole\{timestamp} --checkpoint model_final.pt --experience "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
```

## 🛠 Если ничего не работает

1. **Убедитесь, что DirectX kit файл существует:**
   ```powershell
   Test-Path "C:\Users\zudva\Downloads\IsaacLab\apps\isaacsim_4_5\isaaclab.python.directx.kit"
   ```

2. **Проверьте переменные окружения:**
   ```powershell
   Get-ChildItem Env: | Where-Object {$_.Name -like "*OMNI*"}
   ```

3. **Создайте DirectX kit файл заново:**
   ```powershell
   Copy-Item "apps\isaacsim_4_5\isaaclab.python.kit" "apps\isaacsim_4_5\isaaclab.python.directx.kit"
   # Затем отредактируйте: vulkan = false, renderingAPI = "D3D12"
   ```
