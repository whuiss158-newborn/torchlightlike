extends Control  # 若卡牌是TextureRect/ColorRect，改为对应父类

# 配置项（可自定义）
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)  # 悬浮放大倍数
@export var animation_duration: float = 0.2  # 动画时长（秒）
var default_scale: Vector2 = Vector2(1, 1)  # 默认缩放
var tween: Tween  # 动画对象

func _ready():
	# 关键：开启鼠标检测，否则无法捕获hover事件
	mouse_filter = Control.MOUSE_FILTER_STOP  # 拦截鼠标事件，不穿透到父节点
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND  # 鼠标悬浮显示手型（可选）
	
	# 绑定鼠标信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	## 可选：锚点/轴心居中，避免缩放偏移
	#anchor_center = Vector2(0.5, 0.5)
	pivot_offset = size / 2
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5


# 鼠标进入：放大卡牌
func _on_mouse_entered():
	# 停止之前的动画（避免多次hover导致错乱）
	if is_instance_valid(tween):
		tween.kill()
	
	# 创建Tween动画，平滑缩放
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", hover_scale, animation_duration)

# 鼠标退出：恢复原尺寸
func _on_mouse_exited():
	if is_instance_valid(tween):
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", default_scale, animation_duration)
