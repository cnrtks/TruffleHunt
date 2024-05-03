extends Node3D

@export var spawn_rate = 0.2
@export var max_flowers = 3
@export var x_variance = 0.8
@export var y_variance = 0.2
@export var z_variance = 0.8
@export var angle_variance = PI/6

#set deferred?
var foliage_count

func _ready():
	foliage_count = get_child_count()

func spawn_foliage_on_array(array_of_v3):
	for v3 in array_of_v3:
		if randf() < spawn_rate:
			for f in randi_range(1, max_flowers):
				spawn_random_foliage(v3)

func spawn_random_foliage(v3):
	var new_foliage = get_child(randi_range(0,foliage_count)).duplicate()
	add_child(new_foliage)
	new_foliage.position = v3 + Vector3(randf_range(-x_variance, x_variance), randf_range(-y_variance, y_variance), randf_range(-z_variance, z_variance))
	new_foliage.rotation.y = randf_range(-angle_variance, angle_variance)
	new_foliage.flip_h = randi_range(0, 1)
