extends ParticipantFSM
class_name Bull

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
