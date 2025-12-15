extends Node2D

@export var spawn_interval: float = 1.0
@export var spawn_radius: int = 600
@export var player: CharacterBody2D
@export var max_enemy_num: int = 10

# 简单的敌人配置 - 分别导出场景和权重
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_weights: Array[int] = []

@onready var spawn_timer = $SpawnTimer
var enemy_pool: Array[CharacterBody2D] = []
var min_player_distance = 200

func _ready():
	# 确保权重数组与场景数组长度匹配
	while spawn_weights.size() < enemy_scenes.size():
		spawn_weights.append(100)
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if enemy_pool.size() >= max_enemy_num:
		return
	
	# 选择一个合适的敌人类型
	var selected_enemy = select_enemy_type()
	if not selected_enemy:
		return
	
	# 获取安全的生成位置
	var spawn_pos = get_safe_spawn_position()
	if spawn_pos == Vector2.INF:
		return
	
	# 生成敌人
	var enemy_instance = selected_enemy.instantiate()
	enemy_instance.global_position = spawn_pos
	add_child(enemy_instance)
	enemy_pool.append(enemy_instance)
	
	# 监听敌人死亡事件
	if enemy_instance.has_signal("enemy_death"):
		enemy_instance.enemy_death.connect(_on_enemy_death)

func select_enemy_type():
	# 根据权重选择敌人类型
	if enemy_scenes.is_empty():
		return null
	
	var total_weight = 0
	for i in range(enemy_scenes.size()):
		if enemy_scenes[i]:
			total_weight += spawn_weights[i]
	
	if total_weight <= 0:
		return null
	
	var random_value = randi() % total_weight
	var cumulative_weight = 0
	
	for i in range(enemy_scenes.size()):
		if not enemy_scenes[i]:
			continue
		
		cumulative_weight += spawn_weights[i]
		if random_value < cumulative_weight:
			return enemy_scenes[i]
	
	return null

func get_safe_spawn_position() -> Vector2:
	# 尝试10次生成安全位置
	for i in range(10):
		var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
		var random_dist = randf_range(min_player_distance, spawn_radius)
		var candidate_pos = player.global_position + random_dir * random_dist
		
		# 可以添加额外的碰撞检测
		return candidate_pos
	
	return Vector2.INF

func _on_enemy_death(enemy):
	if enemy_pool.has(enemy):
		enemy_pool.erase(enemy)
