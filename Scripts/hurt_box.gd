extends Area2D

@onready var disable_timer: Timer = $DisableTimer
@export_enum("Colldown", "HitOnce", "Disabled") var HurtBoxType = 0
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal take_damage(damage: int)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					changeTimerDisabled()
					disable_timer.start()
				1: #HitOnce
					pass
				2: #Disabled
					if area.has_method("disableNow"):
						area.call("disableNow")
			var curDamage = area.damage
			take_damage.emit(curDamage)


func _on_disable_timer_timeout() -> void:
	changeTimerDisabled()

func changeTimerDisabled():
	collision_shape_2d.set_deferred("disabled", not collision_shape_2d.get("disabled"))
