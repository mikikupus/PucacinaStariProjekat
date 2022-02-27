extends Spatial
#za weapon sway odnosno lagano pomeranje oruzija
export var sway_normal : Vector3
export var sway_right : Vector3
export var sway_left : Vector3
var kretanje_misa
var sway_prag = 5
var sway_lerp = 5

func _input(event):
	if event is InputEventMouseMotion:
		kretanje_misa = -event.relative.x

func _process(delta):
	if kretanje_misa !=null:
		if kretanje_misa > sway_prag:
			rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
		elif kretanje_misa < -sway_prag:
			rotation = rotation.linear_interpolate(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)
