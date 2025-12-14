extends CharacterBody2D

# 初始血量
var hp: int = 10

# 承受伤害
func _on_hurtbox_take_damage(damage: int, position, knockback) -> void:
	hp -= damage
	print("敌人受击！剩余血量：", hp)

# 处理击退
func apply_knockback(knockback_dir: Vector2, knockback: float) -> void:
	#velocity = knockback_dir * knockback
	pass

# 敌人简单移动（可选，测试跟踪用，这里先静止）
func _physics_process(delta: float) -> void:
	#move_and_slide()
	pass
