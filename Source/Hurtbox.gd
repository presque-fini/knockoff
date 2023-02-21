extends Area2D
class_name Hurtbox

onready var id: int = owner.id

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")

# Cette fonction se déclenche sur le joueur qui reçoit les dommages
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null or id == hitbox.id:
		return

	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.light_damage)
