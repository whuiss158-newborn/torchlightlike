class_name RangedEnemy extends BaseEnemy

# 远程敌人特有属性
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 100.0
@export var attack_range: float = 200.0

func move_ai(delta):
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# 如果在攻击范围内，停止移动并攻击
	if distance_to_player <= attack_range:
		velocity = Vector2.ZERO
		attack()
	else:
		# 否则向玩家移动
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * enemy_data.move_speed
		
		# 更新朝向
		if direction.x > 0.1:
			sprite.flip_h = true
		elif direction.x < -0.1:
			sprite.flip_h = false

func perform_attack():
	if not projectile_scene or not player:
		return
	
	# 创建投射物
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	# 设置投射物方向和速度
	var direction = (player.global_position - global_position).normalized()
	if projectile.has_method("set_velocity"):
		projectile.set_velocity(direction * projectile_speed)
	
	# 设置伤害
	if projectile.has_method("set_damage"):
		projectile.set_damage(enemy_data.attack_damage)
	
	get_parent().add_child(projectile)
