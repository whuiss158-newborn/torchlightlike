extends RefCounted
class_name IHitBehavior

# ===================== 核心抽象方法（命中行为专属） =====================
## 初始化命中参数（范围检测形状、伤害基数等）
## @param weapon: 所属武器实例
func init_hit_params(weapon: Weapon) -> void:
	push_error("IHitBehavior: 子类必须实现 init_hit_params 方法！")

## 处理命中目标逻辑（伤害/击退/范围检测）
## @param weapon: 所属武器实例
## @param target: 命中的目标节点（如敌人）
func process_hit(weapon: Weapon, target: Node2D) -> void:
	push_error("IHitBehavior: 子类必须实现 process_hit 方法！")

## 清理命中相关资源（如临时检测区域）
## @param weapon: 所属武器实例
func cleanup_hit(weapon: Weapon) -> void:
	push_error("IHitBehavior: 子类必须实现 cleanup_hit 方法！")

# ===================== 通用工具方法 =====================
## 获取命中行为配置参数
## @param weapon: 所属武器实例
## @param config_key: 参数名（如 "explosion_radius"）
## @param default_val: 默认值
func get_hit_param(weapon: Weapon, config_key: String, default_val: Variant) -> Variant:
	if weapon.config and weapon.config.hit_config:
		return weapon.config.hit_config.get(config_key, default_val)
	return default_val
