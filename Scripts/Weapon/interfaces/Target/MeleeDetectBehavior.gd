extends ITargetBehavior
class_name MeleeDetectBehavior

func init_target_detection(weapon: Weapon) -> void:
	# 近战检测无需前置参数，初始化范围检测形状（可选）
	pass

func update_target_detection(weapon: Weapon, delta: float) -> Array[Node2D]:
	if not weapon.is_alive:
		return []
	# 1. 获取近战范围（修正：新增通用参数读取逻辑，替代直接调用get_move_param）
	var melee_range = _get_weapon_param(weapon, "move_config", "melee_range", 50.0)
	# 2. 检测范围内的敌人
	var detected_enemies = []
	var all_bodies = weapon.get_overlapping_bodies()
	for body in all_bodies:
		if body.is_in_group("enemy") and weapon.global_position.distance_to(body.global_position) <= melee_range:
			detected_enemies.append(body)
	# 3. 自动触发命中逻辑（近战主动检测）
	for enemy in detected_enemies:
		if weapon.behaviors["hit"]: # 判空避免报错
			weapon.behaviors["hit"].process_hit(weapon, enemy)
	return detected_enemies

func cleanup_target_detection(weapon: Weapon) -> void:
	# 近战检测无额外资源，无需清理
	pass

# ===================== 新增：通用武器参数读取方法 =====================
## 安全读取武器配置中的指定字典参数
## @param weapon: 所属武器实例
## @param config_dict_name: 配置字典名（如 "move_config"/"hit_config"）
## @param config_key: 参数名（如 "melee_range"/"explosion_radius"）
## @param default_val: 默认值
func _get_weapon_param(weapon: Weapon, config_dict_name: String, config_key: String, default_val: Variant) -> Variant:
	if not weapon.config: # 配置为空直接返回默认值
		return default_val
	# 读取指定的配置字典（如 move_config/hit_config）
	var config_dict = weapon.config.get(config_dict_name)
	# 读取字典中的指定参数
	return config_dict.get(config_key, default_val)
