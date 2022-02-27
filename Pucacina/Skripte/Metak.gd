#-------------------------------------------------------------------------------
extends RigidBody
export var damage = 50 #definise se damage
export var speed = 5000 #definise se brzina metka
#-------------------------------------------------------------------------------
func _ready():
	set_as_toplevel(true) #ignorise rotaciju i transform od parenta
#-------------------------------------------------------------------------------
func shoot():
	apply_central_impulse(-transform.basis.z.normalized() * speed) 
#-------------------------------------------------------------------------------
func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= damage #definise damage
		queue_free() #brise
	else:
		queue_free() #brise
#-------------------------------------------------------------------------------
