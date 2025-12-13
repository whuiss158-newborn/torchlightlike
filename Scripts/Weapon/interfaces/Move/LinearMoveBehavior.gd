extends IMoveBehavior
class_name LinearMoveBehavior

func init_move_params(weapon: Weapon) -> void:
	# 1. 计算朝向目标的方向向量
	weapon.angle = weapon.global_position.direction_to(weapon.target)
	# 2. 应用旋转偏移（兼容原有135度偏移逻辑）
	weapon.rotation = weapon.angle.angle() + deg_to_rad(weapon.config.rotation_offset)
	# 3. 初始化缩放动画（视觉基础）
	var tween = weapon.create_tween().set_parallel(true)
	tween.tween_property(weapon, "scale", Vector2(1, 1) * weapon.config.attack_size, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.play()

func update_movement(weapon: Weapon, delta: float) -> void:
	# 仅存活武器执行移动
	if not weapon.is_alive:
		return
	# 直线位移核心逻辑
	weapon.position += weapon.angle * weapon.config.speed * delta

func cleanup_movement(weapon: Weapon) -> void:
	# 直线移动无额外资源，无需清理
	pass
