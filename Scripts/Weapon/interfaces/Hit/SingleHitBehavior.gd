extends IHitBehavior
class_name SingleHitBehavior

func init_hit_params(weapon: Weapon) -> void:
	# 单体命中无前置参数，无需初始化
	pass

func process_hit(weapon: Weapon, target: Node2D) -> void:
	# 1. 校验有效性
	if not weapon.is_alive or not is_instance_valid(target):
		return
	# 2. 获取扣血基数
	var charge = get_hit_param(weapon, "charge", 1)
	# 3. 武器扣血（耐久耗尽则销毁）
	weapon.take_damage(charge)
	# 4. 触发伤害信号（外部系统处理伤害/击退）
	if target.is_in_group("enemy"):
		weapon.hit.emit(weapon, weapon.config.damage, weapon.config.knockback, target)

func cleanup_hit(weapon: Weapon) -> void:
	# 单体命中无额外资源，无需清理
	pass
