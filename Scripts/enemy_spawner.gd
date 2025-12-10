extends Node2D

@export var enemy_scene: PackedScene
@export var swapn_interval: float = 1.0
@export var spawn_radius: int = 600
@export var player: CharacterBody2D
@export var max_enemy_num: int = 10
@onready var spwan_timer = $SpawnTimer
var min_player_distance = 200
var enemy_pool: Array[CharacterBody2D] = []

func _ready() -> void:
	spwan_timer.wait_time = swapn_interval
	spwan_timer.one_shot = false
	spwan_timer.start()

# ===================== 核心生成逻辑 =====================
# 定时器超时触发：尝试生成怪物
func _on_spawn_timer_timeout() -> void:
	spawn_one_enemy()

func spawn_one_enemy():
	# 前置检查：怪物数量未达上限 + 预制体/玩家已赋值
	if enemy_pool.size() >= max_enemy_num or not enemy_scene or not player:
		return
	# 1. 获取安全的随机生成位置（避开玩家+障碍物）
	var spawn_pos = _get_safe_spawn_position()
	if spawn_pos == Vector2.INF:
		return
	var enemy_ins = enemy_scene.instantiate()
	enemy_ins.global_position = spawn_pos
	add_child(enemy_ins)
	enemy_pool.append(enemy_ins)
	

func _get_safe_spawn_position() -> Vector2:
	# 最多尝试10次（避免无限循环），优先找无障碍物的位置
	for i in range(10):
		# 随机方向（0~360度， TAU = 2PI）
		var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
		# 随机距离（介于最小玩家距离和最大半径之间）
		var random_dis = randf_range(min_player_distance, spawn_radius)
		# 计算候选位置
		var candidate_pos = player.global_position + random_dir * random_dis
		
		# 检测位置是否有障碍物 todo
		return candidate_pos
		
	return Vector2.INF
