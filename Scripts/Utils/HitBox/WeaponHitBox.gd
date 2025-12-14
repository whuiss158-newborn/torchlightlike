extends BaseHitBox
class_name WeaponHitBox

# 移除所有父类重复变量！仅保留子类专属逻辑

func _ready() -> void:
	super._ready()  # 调用父类_ready
	# 初始化：设置Weapon专属的目标HurtBox分组（复用父类变量）
	target_hurtbox_group = "hurt_box_enemy"
	# 校验host类型（确保是Weapon）
	if host and not host is Weapon:
		push_error("%s 的host不是Weapon类型！" % name)
		host = null

# 重写父类函数（无override，4.5原生支持）
func _is_host_alive() -> bool:
	# 类型断言：host必须是Weapon且存活
	return host is Weapon and host.is_alive

func _get_final_damage() -> int:
	if host.config.damage:
		print('config.damage', host.config.damage)
	return host.config.damage if (host is Weapon) else attack_damage

func _get_final_knockback() -> float:
	return host.config.knockback if (host is Weapon) else attack_knockback

# Weapon攻击后回调
func _on_hitbox_attack(target: Node, damage: int, hit_pos: Vector2) -> void:
	if host is Weapon and host.has_method("take_damage"):
		host.take_damage(1)
