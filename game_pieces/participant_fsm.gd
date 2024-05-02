extends GamePiece
class_name ParticipantFSM
var States = {}
var state = null:
	set = set_state
var previous_state = null
@onready var parent = get_parent()

func _process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func _state_logic(delta):
	pass

func _get_transition(delta):
	pass

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass

func set_state(new_state):
	print(new_state)
	previous_state = state
	state = new_state
	if previous_state != null: _exit_state(previous_state, state)
	if new_state != null: _enter_state(state, previous_state)

func add_state(state_name):
	States[state_name] = States.size()
