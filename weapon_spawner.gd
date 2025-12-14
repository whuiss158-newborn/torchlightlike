extends Node2D

# 子弹预制体（编辑器绑定）
@export var bullet_prefab: PackedScene = null
@export var enemy_prefab: PackedScene = null
# 生成位置（屏幕左侧）
var spawn_pos: Vector2 = Vector2(100, 300)
var e_spawn_pos: Vector2 = Vector2(500, 800)
var enemy = null
@onready var test_enemy: CharacterBody2D = $TestEnemy

func _ready() -> void:
	enemy = enemy_prefab.instantiate()
	enemy.global_position = e_spawn_pos
	get_tree().current_scene.add_child(enemy)
	# 延迟1秒生成子弹（方便观察）
	await get_tree().create_timer(1.0).timeout
	_spawn_test_bullet()

# 生成测试子弹
func _spawn_test_bullet() -> void:
	# 实例化子弹
	var bullet = bullet_prefab.instantiate() as Weapon
	# 设置生成位置
	bullet.global_position = spawn_pos
	# 设置目标位置（敌人位置）
	bullet.target = test_enemy.global_position
	# 添加到场景
	get_tree().current_scene.add_child(bullet)
	
	# 监听子弹核心信号
	bullet.hit.connect(_on_bullet_hit)
	bullet.destroyed.connect(_on_bullet_destroyed)
	bullet.remove_object_from_list.connect(_on_bullet_remove)
	
	print("测试子弹生成成功！")

# 子弹命中回调
func _on_bullet_hit(weapon: Weapon, damage: int, knockback: float, target: Node2D) -> void:
	print("===== 子弹命中目标 [碰撞检测触发] =====")
	print("武器实例：", weapon.name)
	print("目标节点类型：", target.get_class())
	print("目标分组：", target.get_groups())
	print("伤害值：", damage, " | 击退值：", knockback)
	# 给敌人施加伤害和击退（加空值检查）
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
	if is_instance_valid(target) and target.has_method("apply_knockback"):
		var knockback_dir = target.global_position.direction_to(weapon.global_position)
		target.apply_knockback(knockback_dir, knockback)

# 子弹销毁回调
func _on_bullet_destroyed(weapon: Weapon) -> void:
	print("===== 子弹销毁 =====")
	print("销毁原因：命中目标/超时/屏幕外")

# 子弹移除列表回调（兼容原有逻辑）
func _on_bullet_remove(object: Weapon) -> void:
	print("子弹从外部列表移除")
