extends ParticipantFSM

class_name Player
#TODO: deadzone should be handled by input mapping
var deadzone = 0.5

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
		if Input.is_action_pressed("select"): player_selected_cell()
		var x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		if x > deadzone || x < -deadzone || y > deadzone || y < -deadzone: move_player(x,y)

func move_player(x_axis, y_axis):
	facing = get_facing_from_angle(y_axis,x_axis)
	move_to_next_cell_from_facing()

func player_selected_cell():
	var selected_cell = get_index_next_tile_facing()
	if selected_cell && aggregate_map.aggregate_array[selected_cell].occupant:
		print(aggregate_map.aggregate_array[selected_cell].occupant)
