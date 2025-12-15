class_name BaseEnemy extends CharacterBody2D

signal enemy_death(enemy)
signal remove_object_from_list(object)

@export var enemy_data: EnemyData = null

# 状态变量
var current_health: int = 0
var is_alive: bool = true
var is_attacking: bool = false
var is_stunned: bool = false
var knockback: Vector2 = Vector2.ZERO
var current_state: String = "idle"

# 节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var hurt_box: Area2D = $EnemyHurtBox
@onready var hit_sound: AudioStreamPlayer2D = $sound_hit
@onready var player: CharacterBody2D = null

# 定时器
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

func _ready():
	if enemy_data:
		initialize_enemy()
	player = get_tree().get_first_node_in_group("player")
	
func initialize_enemy():
	current_health = enemy_data.max_health
	is_alive = true
	current_state = "idle"
	
	# 配置视觉和音效
	#if enemy_data.sprite_texture:
		#animated_sprite.sprite_frames = create_animation_frames()
	if enemy_data.hit_sound:
		hit_sound.stream = enemy_data.hit_sound
	
	# 配置攻击参数
	attack_cooldown_timer.wait_time = enemy_data.attack_cooldown
	
	# 播放初始动画
	play_animation("idle")

# 创建动画帧资源
func create_animation_frames() -> SpriteFrames:
	#pass
	var sprite_frames = SpriteFrames.new()
	
	if enemy_data.animation_sprite_sheet:
		# 使用精灵表创建动画
		for anim_name in enemy_data.animation_frames.keys():
			var anim_config = enemy_data.animation_frames[anim_name]
			var frames = []
			
			for frame_index in anim_config.frames:
				var rect = Rect2(
					frame_index % (enemy_data.animation_sprite_sheet.get_width() / enemy_data.frame_size.x) * enemy_data.frame_size.x,
					frame_index / (enemy_data.animation_sprite_sheet.get_width() / enemy_data.frame_size.x) * enemy_data.frame_size.y,
					enemy_data.frame_size.x,
					enemy_data.frame_size.y
				)
				frames.append(rect)
			
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, anim_config.speed)
			
			for rect in frames:
				# 正确传递参数：动画名称、纹理、区域矩形
				sprite_frames.add_frame(anim_name, enemy_data.animation_sprite_sheet, rect)
	else:
		# 如果没有精灵表，使用静态图片创建简单动画
		for anim_name in enemy_data.animation_frames.keys():
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 1.0)
			# 正确传递参数：动画名称、纹理
			sprite_frames.add_frame(anim_name, enemy_data.sprite_texture)
	
	return sprite_frames

# 播放动画
func play_animation(anim_name: String):
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
		current_state = anim_name

func _physics_process(delta):
	if not is_alive or is_stunned:
		return
	
	# 处理击退
	if knockback.length() > 0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, enemy_data.knockback_recovery * delta)
		play_animation("hurt")
	else:
		# 实现移动逻辑
		move_ai(delta)
	
	move_and_slide()

# 移动AI（可被子类重写）
func move_ai(delta):
	if not player:
		play_animation("idle")
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * enemy_data.move_speed
	
	# 更新朝向
	if direction.x > 0.1:
		animated_sprite.flip_h = true
	elif direction.x < -0.1:
		animated_sprite.flip_h = false
	
	# 播放移动动画
	if velocity.length() > 0.1:
		play_animation("move")
	else:
		play_animation("idle")

# 攻击逻辑（可被子类重写）
func attack():
	if is_attacking or not can_attack():
		return
	
	is_attacking = true
	attack_cooldown_timer.start()
	
	# 播放攻击动画
	play_animation("attack")
	
	# 触发攻击动画和效果
	perform_attack()

# 检查是否可以攻击（可被子类扩展）
func can_attack():
	if not player or not is_alive or is_stunned:
		return false
	
	return global_position.distance_to(player.global_position) <= enemy_data.attack_range

# 执行具体攻击（需要子类实现）
func perform_attack():
	pass

# 受击处理
func take_damage(damage: int, hit_position: Vector2, knockback_amount: float):
	if not is_alive:
		return
	
	current_health -= damage
	knockback = (global_position - hit_position).normalized() * knockback_amount
	
	# 播放受击音效和动画
	hit_sound.play()
	play_animation("hurt")
	
	if current_health <= 0:
		die()

# 死亡处理
func die():
	is_alive = false
	
	# 播放死亡动画
	play_animation("death")
	
	# 发出死亡信号
	enemy_death.emit(self)
	remove_object_from_list.emit(self)
	
	# 播放死亡效果
	if enemy_data.death_effect:
		var death_instance = enemy_data.death_effect.instantiate()
		death_instance.global_position = global_position
		get_parent().add_child(death_instance)
	
	# 生成经验值
	spawn_experience()
	
	# 延迟清理敌人
	wait_for_animation_complete()

# 等待动画完成后清理
func wait_for_animation_complete():
	# 创建一个临时定时器等待动画完成
	var timer = Timer.new()
	timer.wait_time = 1.0  # 假设死亡动画持续1秒
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(queue_free)
	timer.start()

# 生成经验值
func spawn_experience():
	var experience_scene = preload("res://Scenes/experience.tscn")
	var exp = experience_scene.instantiate()
	exp.global_position = global_position
	get_parent().add_child(exp)

# 定时器回调
func _on_attack_cooldown_timer_timeout():
	is_attacking = false
	# 回到移动或空闲状态
	if velocity.length() > 0.1:
		play_animation("move")
	else:
		play_animation("idle")
