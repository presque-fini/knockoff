extends Area2D
class_name Hurtbox

onready var id: int = owner.id

func _init() -> void:
	set_collision_layer(4)
	set_collision_mask(18) # 2 + 16

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_killbox")

# Cette fonction se déclenche sur le joueur qui reçoit les dommages
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null or id == hitbox.id:
		return
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.light_damage)


func _killbox(killbox: Killbox) -> void:
	if killbox == null:
		return
	if killbox.has_method("get_name"):
		if killbox.get_name() == "Killbox":
			print("Sortie ", killbox.get_name())
	#	if killbox.id == 666: 
			if owner.has_method("kill"):
				owner.kill()


#func _on_Hurtbox_area_exited(area):
#	print("Sortie", area.get_type())
#	if area.get_class() == "Killbox":
#
#		if owner.has_method("kill"):
#			owner.kill()
