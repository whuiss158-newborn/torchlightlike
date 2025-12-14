extends Control

const CardData = preload("res://Sources/src/CardData.gd")
# 配置项（可自定义）
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)  # 悬浮放大倍数
@export var animation_duration: float = 0.1  # 动画时长（秒）
# === 新增：接收CardData ===
@export var card_data: CardData:
	set(value):
		card_data = value
		# 如果数据被设置（包括在编辑器中），立即应用它
		if card_data and is_inside_tree():
			_apply_card_data()

enum InteractionState {NORMAL, HOVERED, PRESSED, SELECTED}
var interaction_state: InteractionState = InteractionState.NORMAL
var default_scale: Vector2 = Vector2(1, 1)  # 默认缩放
var tween: Tween  # 动画对象
var is_selectable: bool = true # 是否允许被选中（可根据游戏逻辑调整）
# === 新增：子节点的引用（可以通过@onready自动获取） ===
@onready var name_label: Label = $NameLabel
@onready var desc_label: Label = $DescLabel
@onready var icon_texture: TextureRect = $ColorRect/IconTexture
#@onready var rarity_border: ColorRect = $RarityBorder # 一个用于显示稀有度颜色的色块
#@onready var type_icon: Sprite2D = $TypeIcon # 用于显示类型的小图标

signal card_selected

func _ready():
	# 关键：开启鼠标检测，否则无法捕获hover事件
	mouse_filter = Control.MOUSE_FILTER_STOP  # 拦截鼠标事件，不穿透到父节点
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND  # 鼠标悬浮显示手型（可选）
	
	# 绑定鼠标信号
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	## 可选：锚点/轴心居中，避免缩放偏移
	await get_tree().process_frame
	pivot_offset = size / 2
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5
	# 应用卡片数据（如果在编辑器中已赋值，或之后通过代码赋值）
	if card_data:
		_apply_card_data()

# === 新增：应用数据到UI的核心函数 ===
func _apply_card_data():
	if not card_data:
		return

	# 1. 应用基础文本和图标特效
	name_label.text = card_data.card_name
	desc_label.text = card_data.description
	icon_texture.texture = card_data.icon
	#_set_rarity_style(card_data.rarity)
	
	# 3. 根据类型设置类型图标或背景色
	#_set_type_style(card_data.type)

# 处理GUI输入事件（用于检测点击）
func _on_gui_input(event: InputEvent):
	# 判断是否为鼠标点击事件
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: # 鼠标按下
				_set_state(InteractionState.PRESSED)
			else: # 鼠标释放（完整的点击动作）
				if interaction_state == InteractionState.PRESSED:
					# 鼠标在卡片上释放，视为一次有效点击
					_handle_card_clicked()
				# 释放后，根据鼠标位置决定状态
				if get_global_rect().has_point(get_global_mouse_position()):
					_set_state(InteractionState.HOVERED)
				else:
					_set_state(InteractionState.NORMAL)

# 鼠标进入：切换为悬停状态
func _on_mouse_entered():
	if interaction_state == InteractionState.NORMAL:
		_set_state(InteractionState.HOVERED)

# 鼠标退出：恢复正常状态（如果未被按下或选中）
func _on_mouse_exited():
	if interaction_state == InteractionState.HOVERED:
		_set_state(InteractionState.NORMAL)

# 核心：统一状态切换和视觉反馈
func _set_state(new_state: InteractionState):
	# 如果状态未改变，则不做任何事
	if interaction_state == new_state:
		return

	var old_state = interaction_state
	interaction_state = new_state

	# 根据新状态执行动画和逻辑
	match new_state:
		InteractionState.NORMAL:
			_play_scale_animation(default_scale)
			print("状态：正常")
		InteractionState.HOVERED:
			_play_scale_animation(hover_scale)
			print("状态：悬停")
		InteractionState.PRESSED:
			# 可以添加一个按下时的微缩效果，增强手感
			_play_scale_animation(hover_scale * 0.97)
			print("状态：按下")
		InteractionState.SELECTED:
			# 选中状态可以有不同的表现，比如更高的亮度或不同的缩放
			_play_scale_animation(hover_scale * 1.05)
			print("状态：选中")
	# 这里可以触发自定义信号，通知其他系统状态改变了
	# emit_signal("interaction_state_changed", old_state, new_state)

# 处理卡片被点击后的核心逻辑
func _handle_card_clicked():
	print("卡片被点击！")
	# 这里放入你的游戏逻辑，例如：
	if is_selectable:
		# 切换选中状态
		if interaction_state != InteractionState.SELECTED:
			_set_state(InteractionState.SELECTED)
		else:
			# 如果已经是选中状态，则取消选中
			_set_state(InteractionState.HOVERED)

	# 示例：发出一个自定义信号，让其他节点（如游戏管理器）处理
	emit_signal("card_selected")
	
# 播放缩放动画
func _play_scale_animation(target_scale: Vector2):
	if is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", target_scale, animation_duration)
