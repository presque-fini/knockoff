extends Area2D
class_name Hitbox

export onready var id: int = owner.id

func _init() -> void:
	collision_layer = 2
	collision_mask = 4

export var light_damage: = 10.0
