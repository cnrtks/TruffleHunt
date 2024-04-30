extends ParticipantFSM
class_name Bull

var debug_marker = preload("res://game_pieces/debug_marker.tscn")

#likely used for other gamepeices, move ther if needed
var visible_range = 4
var facing = 0


func _ready():
	call_deferred("get_wedge_from_facing")

#state machine
	#called in _processs
func _state_logic(delta):
	pass

	#called in _process
func _get_transition(delta):
	match state:
		States.IDLE:
			if walk_tween != null && walk_tween.is_running(): return States.IN_TRANSIT
		States.IN_TRANSIT:
			if !walk_tween.is_running(): return States.IDLE

func _enter_state(new_state, old_state):
	match new_state:
		States.IDLE:
			#put animations in here apparently
			pass

func _exit_state(old_state, new_state):
	pass
#end of state machine

func scan_for_targets():
	get_wedge_from_facing()

#move to gamepice if used by others
func get_wedge_from_facing():
	var tile_array = []
#NE and SW (2 and 5) count as cardinal becasue the wedge shapes have a strghit column away from the origin which reduces until reaching the origin
	var cardinal = facing % 3 == 2
	var negative_north = -1 if facing < 2 else 1
	var negative_west = 1 if facing > 0 && facing < 4 else -1
	var column_origin = cell.map
	if cardinal: column_origin = Vector3i(cell.map.x + negative_west * visible_range, 0, cell.map.z - visible_range)
	
	
	#var column_end = Vector3i(column_origin.x, column_origin.y, column_origin.z + visible_range * 2 * negative_north)
	#var row_min = column_origin.z
	#var row_max = column_end.z
	
	for q in 2* visible_range:
		for r in range(q, 2 * visible_range -1):
			if q%2 == r%2: debug_tile(Vector3i(column_origin.x + q, 0, column_origin.z + r))
	
	#for t in tile_array:
		#debug_tile(t)

func debug_tile(v3i):
	var debug_start = debug_marker.instantiate()
	parent.add_child(debug_start)
	print(v3i)
	debug_start.position = aggregate_map.grid_map.map_to_local(v3i)

func debug_tiles(i):
	var debug_start = debug_marker.instantiate()
	parent.add_child(debug_start)
	debug_start.position = aggregate_map.grid_map.map_to_local(aggregate_map.aggregate_array[i].map)
	
