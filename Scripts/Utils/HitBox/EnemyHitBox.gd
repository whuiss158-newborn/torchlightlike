extends BaseHitBox
class_name EnemyHitBox

@export var enemy_attack_damage: int = 2
@export var enemy_attack_knockback: float = 80.0

func _ready() -> void:
	super._ready()  # 调用父类_ready
	# 初始化：设置Enemy专属的目标HurtBox分组（复用父类变量）
	target_hurtbox_group = "hurt_box_player"
	# 校验host类型（确保是Enemy/CharacterBody2D）
	if host and not host is CharacterBody2D:
		push_error("%s 的host不是CharacterBody2D类型！" % name)
		host = null

# 重写父类函数
func _is_host_alive() -> bool:
	# 类型断言：host必须是CharacterBody2D且血量>0
	return host is CharacterBody2D and host.hp > 0

func _get_final_damage() -> int:
	return enemy_attack_damage

func _get_final_knockback() -> float:
	return enemy_attack_knockback

# Enemy攻击后回调
func _on_hitbox_attack(target: Node, damage: int, hit_pos: Vector2) -> void:
	if host is CharacterBody2D:
		var enemy_host = host  # 赋值给具体类型变量
		var sound_hit_node = enemy_host.get_node_or_null("sound_hit")
		if sound_hit_node is AudioStreamPlayer2D:
			sound_hit_node.play()
