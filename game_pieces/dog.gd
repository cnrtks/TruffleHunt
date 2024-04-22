extends ParticipantFSM

class_name Dog

@export var run_speed = 0.15
@export var dig_speed =  6
@export var idle_search = 2
var follow_target = null
var rummage_tween = null

func _ready():
	follow_target = get_tree().root.get_node("Main/Player")
	walk_speed = 1
	add_state("IDLE")
	add_state("IN_TRANSIT")
	add_state("DIGGING")
	add_state("RUMMAGING")
	call_deferred("set_state", States.IDLE)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match state:
		States.IDLE:
			if walk_tween != null && walk_tween.is_running(): return States.IN_TRANSIT
			elif rummage_tween != null && rummage_tween.is_running(): return States.RUMMAGING
		States.IN_TRANSIT:
			if !walk_tween.is_running(): return States.IDLE
		States.RUMMAGING:
			if !rummage_tween.is_running(): return States.IDLE

func _enter_state(new_state, old_state):
	match new_state:
		States.IDLE:
			if follow_target != null:
				walk_near_follow_target()

func _exit_state(old_state, new_state):
	if old_state == States.IN_TRANSIT && new_state == States.IDLE:
		#this timer should be interrupted by commands and stuff
		await get_tree().create_timer(3).timeout
		rummage()

#a geneeric animation for when the dog is not really doing anything important just sniffing the ground and stuff
func rummage():
#TODO: replace this tween wityh an animation
	var idle_tween = create_tween().set_loops(3)
	idle_tween.tween_property(self, "position:y", 1, 2)
	idle_tween.tween_property(self, "position:y", .5, 2)
	await idle_tween.finished
	#change_state(State.IN_TRANSIT)

#this could probably just be deleted, it gets the dog to just sort of wander around
func walk_to_nearby_tile():
	var random_neighbor = get_neighbors_in_range(idle_search).pick_random()
	walk_to_far_cell(aggregate_map.aggregate_array[random_neighbor])

func walk_near_follow_target():
	if follow_target != null:
		var random_neighbor = follow_target.get_neighbors_in_range(idle_search).pick_random()
		walk_to_far_cell(aggregate_map.aggregate_array[random_neighbor])

func dig():
#TODO: replace this with animation
	var search_tween = create_tween()
	search_tween.tween_property(self, "rotation:x", PI/4, dig_speed)
	search_tween.tween_property(self, "rotation:x", 0, dig_speed)
	await search_tween.finished
	
