extends Area2D

@onready var disable_timer: Timer = $DisableTimer
@export_enum("Colldown", "HitOnce", "Disabled") var HurtBoxType = 0
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal take_damage(damage: int, hitPosition: Vector2, knockback)

var hitted_array: Array[Area2D] = []

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					changeTimerDisabled()
					disable_timer.start()
				1: #HitOnce
					if hitted_array.has(area) == false:
						hitted_array.append(area)
						if area.has_signal("remove_object_from_list"):
							if not area.is_connected("remove_object_from_list", Callable(self, "remove_item_from_hit_arr")):
								area.connect("remove_object_from_list", Callable(self, "remove_item_from_hit_arr"))
					else:
						return
				2: #Disabled
					if area.has_method("disableNow"):
						area.call("disableNow")
			var curDamage = area.damage
			var knockback = 1
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			take_damage.emit(curDamage, area.global_position, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_item_from_hit_arr(obj):
	hitted_array.erase(obj)

func _on_disable_timer_timeout() -> void:
	changeTimerDisabled()

func changeTimerDisabled():
	collision_shape_2d.set_deferred("disabled", not collision_shape_2d.get("disabled"))
