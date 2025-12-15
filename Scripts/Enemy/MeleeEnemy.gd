class_name MeleeEnemy extends BaseEnemy

# 近战敌人特有属性
@export var attack_radius: float = 30.0

func perform_attack():
	# 检查玩家是否在攻击范围内
	if not player or global_position.distance_to(player.global_position) > attack_radius:
		return
	
	# 对玩家造成伤害
	var damage = enemy_data.attack_damage
	var knockback = 20.0
	
	# 通过玩家的伤害盒子传递伤害
	if player.has_node("PlayerHurtBox"):
		var player_hurt_box = player.get_node("PlayerHurtBox")
		if player_hurt_box.has_signal("take_damage"):
			player_hurt_box.take_damage.emit(damage, global_position, knockback)
