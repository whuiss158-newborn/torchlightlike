# TestScene.gd
extends Control
@onready var card_data_script = preload("res://Sources/src/CardData.gd")

func _ready():
	 # 尝试直接预加载脚本文件本身
	print("脚本加载成功:", card_data_script)
	# 尝试从脚本创建实例
	var instance = card_data_script.new()
	print("实例创建成功:", instance)
	print("它是Resource吗？", instance is Resource)
	# 添加测试按钮
	var test_button = Button.new()
	test_button.text = "测试卡牌生成"
	test_button.position = Vector2(100, 100)
	test_button.pressed.connect(_test_card_generation)
	add_child(test_button)

func _test_card_generation():
	print("=== 手动测试卡牌生成 ===")
	
	# 测试2: 直接生成CardData
	var test_card_data = CardData.create_random_card_by_type(
		CardData.CardType.ATTACK, 
		CardData.Rarity.COMMON
	)
	print("✅ 测试卡牌数据生成成功")
	print("   卡牌名称: ", test_card_data.card_name)
	print("   攻击力: ", test_card_data.attack_power)
	
	# 测试3: 使用GameManager生成
	print("\n=== 测试GameManager生成 ===")
	# 确保GameManager已加载
	if GameManager == null:
		print("❌ GameManager未加载，请检查自动加载设置")
		return
	
	print("✅ GameManager已加载")
	
	# 调用GameManager的生成函数
	var gm_card_data = GameManager._generate_random_card_data()
	print("✅ GameManager生成的卡牌: ", gm_card_data.card_name)
	
	# 测试4: 实例化卡片场景
	print("\n=== 测试卡片场景实例化 ===")
	var card_scene = preload("res://Scenes/upgrade_card_item.tscn")
	var card_instance = card_scene.instantiate()
	
	# 检查卡片实例是否有card_data属性 - 正确的方法
	print("检查卡片实例类型: ", card_instance.get_class())
	
	# 方法1: 使用has_method检查是否有set_card_data方法
	if card_instance.has_method("set_card_data"):
		print("✅ 卡片实例有set_card_data方法")
		card_instance.set_card_data(gm_card_data)
		print("✅ 成功设置卡牌数据到实例")
		
		# 如果卡片有更新UI的方法，调用它
		if card_instance.has_method("update_display"):
			card_instance.update_display()
	else:
		print("❌ 卡片实例没有set_card_data方法")
		
		# 方法2: 直接尝试设置属性
		var script_holder = card_instance.get_node("Container")
		if script_holder and "card_data" in script_holder:
			script_holder.card_data = gm_card_data
			print("✅ 直接设置card_data属性成功")
		else:
			print("❌ 卡片实例的Container子节点没有card_data属性")
			
			# 打印卡片实例的所有可用的属性和方法
			print("\n卡片实例的可用方法:")
			var methods = card_instance.get_method_list()
			for method in methods:
				if method.name.begins_with("set_") or method.name.contains("card"):
					print("  - ", method.name)
			
			print("\n卡片实例的可用属性:")
			var properties = card_instance.get_property_list()
			for prop in properties:
				var prop_name = prop["name"]
				if prop_name == "card_data" or prop_name.contains("card"):
					print("  - ", prop_name, " (类型: ", prop["type"], ")")
	
	# 将卡片添加到场景中查看
	card_instance.position = Vector2(200, 200)
	add_child(card_instance)
	print("✅ 卡片已添加到场景中，位置: ", card_instance.position)
