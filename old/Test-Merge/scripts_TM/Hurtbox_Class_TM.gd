class_name Hurtbox_TM
extends Area2D

onready var Hurtbox_id = owner.id

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered",self, "_on_area_entered")

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	if hitbox.Hitbox_id == Hurtbox_id:
		return
		
	elif owner.has_method("take_damage"):
		print("hurtbox : ", Hurtbox_id)
		print("hitbox : ", hitbox.Hitbox_id)
		print("Player: ", owner.id)
		
		owner.take_damage(hitbox.light_damage)
