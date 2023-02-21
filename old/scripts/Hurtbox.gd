class_name Hurtbox_temp

extends Area2D

onready var id = owner.id

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null or id == hitbox.Hitbox_id:
		return

	if owner.has_method("take_damage"):
		print("hurtbox : ", id)
		print("hitbox : ", hitbox.Hitbox_id)
		print("Player: ", owner.id)
		
		owner.take_damage(hitbox.light_damage)
