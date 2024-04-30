extends ParticipantFSM

class_name Player
#TODO: deadzone should be handled by input mapping
var deadzone = 0.5
var facing = 0

func _ready():
	walk_speed = 0.3
	add_state("IDLE")
	add_state("IN_TRANSIT")
	add_state("INTERACTION")
	call_deferred("set_state", States.IDLE)

#state machine
	#called in _processs
func _state_logic(delta):
	_handle_move_input()

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

func _handle_move_input():
	if state == States.IDLE:
		if Input.is_action_pressed("select"): parent.player_selected_cell()
		var x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		if x > deadzone || x < -deadzone || y > deadzone || y < -deadzone: move_player(x,y)

func move_player(x_axis, y_axis):
	facing = int((atan2(y_axis, x_axis)/PI+1)*3)
	var next_index = get_index_player_facing()
	if next_index != null && !aggregate_map.astar.is_point_disabled(next_index):
		walk_to_next_cell(aggregate_map.aggregate_array[next_index])
		aggregate_map.switch_occupant_cells(self, next_index)

func get_index_player_facing():
	var south = facing > 2
	var next_index
	if facing % 3 == 1:
		next_index = aggregate_map.get_index_from_coords(Vector3i(cell.map.x, 0 , cell.map.z + (2 if south else -2)))
	else:
		next_index = aggregate_map.get_index_from_coords(Vector3i(cell.map.x + (
			1 if facing == 2 || facing == 3 else -1),
			0,
			cell.map.z + (1 if south else -1)))
	return next_index

func player_selected_cell():
	var selected_cell = get_index_player_facing()
	if selected_cell && $AggregateMap.aggregate_array[selected_cell].occupant:
		print($AggregateMap.aggregate_array[selected_cell].occupant)
