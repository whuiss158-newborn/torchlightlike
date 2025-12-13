extends RefCounted
class_name ITargetBehavior

# ===================== 核心抽象方法（目标检测专属） =====================
## 初始化目标检测（范围形状、目标分组等）
## @param weapon: 所属武器实例
func init_target_detection(weapon: Weapon) -> void:
	push_error("ITargetBehavior: 子类必须实现 init_target_detection 方法！")

## 更新目标检测（帧检测范围内/可锁定的目标）
## @param weapon: 所属武器实例
## @param delta: 帧时间增量
## @return Array[Node2D]: 检测到的目标列表
func update_target_detection(weapon: Weapon, delta: float) -> Array[Node2D]:
	push_error("ITargetBehavior: 子类必须实现 update_target_detection 方法！")
	return []

## 清理目标检测资源（移除检测区域）
## @param weapon: 所属武器实例
func cleanup_target_detection(weapon: Weapon) -> void:
	push_error("ITargetBehavior: 子类必须实现 cleanup_target_detection 方法！")
