extends IVFXBehavior
class_name DefaultVFXBehavior

func init_vfx_resources(weapon: Weapon) -> void:
	pass
	# 预加载特效（可选，避免运行时加载卡顿）
	#if weapon.config.spawn_vfx_path != "":
		#preload(weapon.config.spawn_vfx_path)
	#if weapon.config.hit_vfx_path != "":
		#preload(weapon.config.hit_vfx_path)
	#if weapon.config.destroy_vfx_path != "":
		#preload(weapon.config.destroy_vfx_path)

func play_spawn_vfx(weapon: Weapon) -> void:
	# 播放生成特效
	if weapon.config.spawn_vfx_path == "":
		return
	var vfx_scene = load(weapon.config.spawn_vfx_path)
	var vfx = vfx_scene.instantiate()
	vfx.global_position = weapon.global_position
	weapon.get_tree().current_scene.add_child(vfx)
	# 特效自动销毁（假设特效节点有自动销毁逻辑）

func play_hit_vfx(weapon: Weapon, target: Node2D) -> void:
	# 播放命中特效
	if weapon.config.hit_vfx_path == "" or not is_instance_valid(target):
		return
	var vfx_scene = load(weapon.config.hit_vfx_path)
	var vfx = vfx_scene.instantiate()
	vfx.global_position = target.global_position
	weapon.get_tree().current_scene.add_child(vfx)

func play_destroy_vfx(weapon: Weapon) -> void:
	# 播放销毁特效
	if weapon.config.destroy_vfx_path == "":
		return
	var vfx_scene = load(weapon.config.destroy_vfx_path)
	var vfx = vfx_scene.instantiate()
	vfx.global_position = weapon.global_position
	weapon.get_tree().current_scene.add_child(vfx)

func cleanup_vfx(weapon: Weapon) -> void:
	# 无额外资源需清理（特效节点自动销毁）
	pass
