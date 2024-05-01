extends ParticipantFSM
class_name Bull

var debug_marker = preload("res://game_pieces/debug_marker.tscn")

#likely used for other gamepeices, move ther if needed
@export var visible_range_short = 3
@export var visible_range_long = 5
@export var idle_search = 2
var facing = 0
#if target is a location it sets bull to walk but if target is a game peicer its charign, this is perhaps a stupid way of doijng things
var target = null
var scan_ray_tween = null
var graze_tween = create_tween()
const ANGLE_OFFSET = TAU / 12 - PI
var short_range_targets = {}
var long_range_targets = {}

func _ready():
	$Horn/RayCastRage.target_position.y = visible_range_short * 2 - 1
	$Horn/RayCastCurious.target_position.y = visible_range_long * 2 - 1
	add_state("IDLE")
	add_state("GRAZING")
	add_state("SCANNING")
	add_state("TRACKING")
	add_state("CHARGING")
	call_deferred("set_state", States.SCANNING)


#state machine
	#called in _processs
	#only put things in here that should fire on every update but should always be firing if enabled, i guess
func _state_logic(delta):	
	var short_range_target = $Horn/RayCastRage.get_collider()
	var long_range_target = $Horn/RayCastCurious.get_collider()
	if short_range_target != null:
		short_range_targets[short_range_target.get_parent().get_parent()] = true
	if long_range_target != null && long_range_target != short_range_target:
		long_range_targets[long_range_target.get_parent().get_parent()] = true

	#called in _process
func _get_transition(delta):
	match state:
		States.IDLE:
			if walk_tween != null && walk_tween.is_running(): return States.TRACKING
		States.TRACKING:
			if !walk_tween.is_running():
				if target: return States.SCANNING
				else: return States.GRAZING
		States.SCANNING:
			if scan_ray_tween != null && !scan_ray_tween.is_running():
				return States.TRACKING
				#return States.GRAZING
		States.GRAZING:
			if !graze_tween.is_running():
				return States.SCANNING

func _enter_state(new_state, old_state):
	match new_state:
		States.IDLE:
			#put animations in here apparently
			pass
		States.SCANNING:
			$Horn/RayCastRage.enabled = true
			$Horn/RayCastCurious.enabled = true
			scan_for_targets()
		States.TRACKING:
			if target:
				print("slow walk to ", target)
				walk_to_far_cell(target)
			else:
				walk_to_random_nearby_tile()
		States.GRAZING:
			graze()
		States.CHARGING:
			print("charging at", target)

func _exit_state(old_state, new_state):
	match old_state:
		States.TRACKING:
			target = null
			if new_state == States.IDLE: set_state(States.GRAZING)
		States.SCANNING:
			short_range_targets = {}
			long_range_targets = {}
			$Horn/RayCastRage.enabled = false
			$Horn/RayCastCurious.enabled = false
#end of state machine

func scan_for_targets():
	var angle = lerp_angle($Horn.rotation.y, (facing -1) * TAU / 6 + ANGLE_OFFSET, 1)
	scan_ray_tween = create_tween()
	scan_ray_tween.tween_property($Horn, "rotation:y", angle, 1)
	await scan_ray_tween.finished
	var enragers = []
	var intriguers = []
#TODO: clean this up a bit, it feels like too much repeated code and too many array interations
	if !short_range_targets.is_empty():
		enragers = short_range_targets.keys().filter(func(t): return t.is_in_group("BullEnrager"))
		if enragers.size() < 1: intriguers = short_range_targets.keys().filter(func(t): return t.is_in_group("BullIntriguer"))
#TODO: current design is to ignore things hidden behind stuff if there is something unobstructed but further away, to change the priority to closer regardless of obstruction remove teh  last boolean chack and replace intrguers = with intriguers.append
	if !long_range_targets.is_empty() && enragers.size() < 1 && intriguers.size() < 1:
		intriguers = long_range_targets.keys().filter(func(t): return t.is_in_group("BullEnrager") || t.is_in_group("BullIntriguer"))
	if enragers.size() > 0:
		target = get_closest_target(enragers)
		set_state(States.CHARGING)
	elif intriguers.size() > 0:
		target = get_closest_target(intriguers).cell

func walk_to_random_nearby_tile():
	var random_neighbor = get_neighbors_in_range(idle_search).pick_random()
	walk_to_far_cell(aggregate_map.aggregate_array[random_neighbor])

func graze():
#TODO:replace with animation
	graze_tween = create_tween().set_loops(1)
	graze_tween.tween_property(self, "position:y", 1, 0.5)
	graze_tween.tween_property(self, "position:y", 0, 0.5)
	await graze_tween.finished
	facing = (facing + 1) % 6

#returns the target and not the path for a few reasons, but mainly becasue the path is irrelevant if the target can move
func get_closest_target(array_of_targets):
	var closest_target = array_of_targets[0]
	var closest_path = aggregate_map.astar.get_point_path(cell.index, closest_target.cell.index)
	for t in range(1, array_of_targets.size()):
		if aggregate_map.astar.get_point_path(cell.index, array_of_targets[t].cell.index).size() < closest_path.size():
			closest_target = array_of_targets[t]
			closest_path = aggregate_map.astar.get_point_path(cell.index, closest_target)
	return closest_target
