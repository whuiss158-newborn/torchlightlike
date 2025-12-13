extends RefCounted
class_name IMoveBehavior

# ===================== 核心抽象方法（移动行为专属） =====================
## 初始化移动参数（方向、旋转、动画等）
## @param weapon: 所属武器实例
func init_move_params(weapon: Weapon) -> void:
	push_error("IMoveBehavior: 子类必须实现 init_move_params 方法！")

## 物理帧更新移动逻辑（位移/转向/姿态变化）
## @param weapon: 所属武器实例
## @param delta: 物理帧时间增量
func update_movement(weapon: Weapon, delta: float) -> void:
	push_error("IMoveBehavior: 子类必须实现 update_movement 方法！")

## 清理移动相关资源（如定时器、临时节点）
## @param weapon: 所属武器实例
func cleanup_movement(weapon: Weapon) -> void:
	push_error("IMoveBehavior: 子类必须实现 cleanup_movement 方法！")

# ===================== 通用工具方法 =====================
## 获取移动行为配置参数
## @param weapon: 所属武器实例
## @param config_key: 参数名（如 "track_speed"）
## @param default_val: 默认值（参数不存在时返回）
func get_move_param(weapon: Weapon, config_key: String, default_val: Variant) -> Variant:
	if weapon.config and weapon.config.move_config:
		return weapon.config.move_config.get(config_key, default_val)
	return default_val
