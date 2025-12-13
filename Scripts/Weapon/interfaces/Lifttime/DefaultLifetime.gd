extends ILifetimeBehavior
class_name DefaultLifetimeBehavior

# 私有变量：超时定时器
var _lifetime_timer: Timer = null

func init_lifetime(weapon: Weapon) -> void:
	# 1. 创建超时定时器
	_lifetime_timer = Timer.new()
	_lifetime_timer.wait_time = weapon.config.lifetime
	_lifetime_timer.one_shot = true
	_lifetime_timer.timeout.connect(func():
		if weapon.is_alive:
			weapon.destroy()
	)
	# 2. 挂载定时器到武器节点
	weapon.add_child(_lifetime_timer)
	_lifetime_timer.start()
	# 3. 绑定屏幕外销毁信号（需武器节点挂载 VisibleOnScreenNotifier2D）
	if weapon.has_node("VisibleOnScreenNotifier2D"):
		var notifier = weapon.get_node("VisibleOnScreenNotifier2D")
		notifier.screen_exited.connect(func():
			if weapon.is_alive:
				weapon.destroy()
		)

func check_lifetime_status(weapon: Weapon, delta: float) -> void:
	# 生命周期状态由定时器/屏幕外信号处理，帧更新无需额外逻辑
	pass

func cleanup_lifetime(weapon: Weapon) -> void:
	# 清理定时器
	if is_instance_valid(_lifetime_timer):
		_lifetime_timer.queue_free()
