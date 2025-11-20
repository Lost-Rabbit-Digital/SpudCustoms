---
description: Optimize performance of a system using object pooling and efficiency patterns
---

Optimize the performance of the specified system.

**Optimization Techniques:**

1. **Object Pooling** (for frequently spawned objects):
```gdscript
class_name ObjectPool
extends Node

var _pool: Array[Node] = []
var _scene: PackedScene

func get_instance() -> Node:
    if _pool.size() > 0:
        return _pool.pop_back()
    return _scene.instantiate()

func return_instance(instance: Node) -> void:
    instance.visible = false
    _pool.append(instance)
```

2. **Reduce _process() Overhead**:
   - Use timers for periodic checks
   - Use signals for event-driven updates
   - Cache frequently accessed values
   - Avoid get_node() calls in _process()

3. **Batch Operations**:
   - Process multiple items per frame
   - Use call_deferred for non-critical updates
   - Spread expensive operations over multiple frames

4. **Memory Management**:
   - Call queue_free() on unused nodes
   - Clear large arrays when done
   - Unload unused resources

**Systems Needing Optimization** (from GDD):
- Footprint system (currently creates/destroys sprites)
- Particle systems (no cleanup plan documented)
- Queue spawning (could use pooling)
- Explosion VFX (frequently spawned)

**Profiling:**
- Use Godot's built-in profiler
- Identify bottlenecks before optimizing
- Measure performance before and after
- Target 60 FPS on minimum spec hardware

Ask the user which system needs optimization if not specified.
