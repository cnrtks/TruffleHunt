extends Node3D

var pine = preload("res://game_pieces/pine.tscn")
var truffle = preload("res://game_pieces/truffle.tscn")

@export var player_spawn: Vector3i = Vector3i(9,0,9)
@export var pet_spawn: Vector3i = Vector3i(10 ,0, 10)
var pine_spawn = [Vector3i(5,0, 9)]

#map ready functions
func _ready():
	$AggregateMap.ready_aggregate_array($GridMap)
	plant_trees()
#learn how to make constructors in gdscript
	$Player.aggregate_map = $AggregateMap
	$Dog.aggregate_map = $AggregateMap
	$Dog.follow_target = $Player
	$Player.place_at_map_coords(player_spawn, true)
	$Dog.place_at_map_coords(pet_spawn, true)
	#walk_to_far_cell($Player, Vector3i(9,0,9))

func plant_trees():
	for p in pine_spawn:
		var new_pine = pine.instantiate()
		new_pine.aggregate_map = $AggregateMap
		add_child(new_pine)
		var aggregate_index = new_pine.place_at_map_coords(p, true)
		new_pine.dig_tiles = plant_truffle(aggregate_index)

#TODO: this does not take imnto account truffle blockers(other truffles, neraby trees)
func plant_truffle(pine_index):
	var potential_truffle_cells = $AggregateMap.astar.get_point_connections(pine_index)
	var new_truffle = truffle.instantiate()
	new_truffle.aggregate_map = $AggregateMap
	add_child(new_truffle)
	new_truffle.place_at_aggregate_index(potential_truffle_cells[randi_range(0, potential_truffle_cells.size() - 1)], false)
	return potential_truffle_cells

#TODO: this probably bleongs in a pet class but it calls astar
#TODO: this seems a bit long considering its just returning coordiantes
func get_nearest_searchable_object(coords):
	var pines = $AggregateMap.aggregate_array.filter(func(i): return i.cell.occupant.is_in_group("searchable"))
	var pines_size = pines.size()
	var pine_to_search = null
	if pines_size > 0:
		pine_to_search = pines[0].map
		if pines_size > 1:
			var path_to_pine
			for p in range(1, pines_size-1):
				var alt_path = $AggregateMap.astar.get_point_path($AggregateMap.get_index_from_coords(coords), pines[p].cell.index)
				if  alt_path.size() < path_to_pine.size():
					pine_to_search = pines[p].map
					path_to_pine = alt_path
	return pine_to_search
