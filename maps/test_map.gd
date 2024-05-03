extends Node3D

#this is a singleton but it gets a child of player when the map is being gnerated becasue its using a spawn tile, maybe fix this
var Player
var Pet
var player = preload("res://game_pieces/player.tscn")
var pet = preload("res://game_pieces/dog.tscn")
var bull = preload("res://game_pieces/bull.tscn")
var pine = preload("res://game_pieces/pine.tscn")
var truffle = preload("res://game_pieces/truffle.tscn")

#TODO: these index numbers are hard coded to the order of the items in the Grid map, should be pased in from parent
#change the order of grid map so that spawners are firs(or last) and are grouped based on behavior
#if you end up with extra tiles in the grid map which should not be there, dlete it, reload, export the tiles, then close and reopen
var spawn_tiles = [0, 1, 2, 3,]

#map ready functions
func _ready():
	$AggregateMap.ready_aggregate_array($GridMap)
	spawn_from_grid_map()
	spawn_foliage()

#TODO:this should probably be in aggregate map or combined with the ready function
#TODO: used cells gives me the same cell like 50 times, try to figure out why or add all used cells to a dictionary so the cells are unique (FILTER DOES NOT WORK ON DICT but this can presumably be bypassed by getting all the values of a some dict, idk
func spawn_from_grid_map():
	var used_cells = $AggregateMap.grid_map.get_used_cells()
	for c in used_cells:
		var tile_index = $AggregateMap.grid_map.get_cell_item(c)
		if spawn_tiles.has(tile_index): spawn_tile(c, tile_index)

func spawn_tile(map_coordinates, grid_item_index):
#TODO: some of this is too specific to the case (player being a singleton here makes noi sense and dog getting player here makes no sense)
	match grid_item_index:
		0: 
			Player = spawn_game_piece(player, map_coordinates, false)
			#TODO: this is only here in case the pet spawner is placed down after the player tile, this can be removed if you are consistent in tile placement for the map
			if Pet != null:
				Pet.follow_target = Player
		1:
			Pet = spawn_game_piece(pet, map_coordinates, false)
			Pet.follow_target = Player
		2:
			var new_bull = spawn_game_piece(bull, map_coordinates, false)
		3: plant_tree(pine, map_coordinates)
		_: print("spawn for %i not implemented", grid_item_index)

#TODO: this adds inherited variables which shoudl maybe be done elsewhere
func spawn_game_piece(game_piece, map_coordinates, disabled):
	var new_piece = game_piece.instantiate()
	add_child(new_piece)
	new_piece.aggregate_map = $AggregateMap
	new_piece.place_at_map_coords(map_coordinates, disabled)
	return new_piece

func plant_tree(game_piece, map_coordinates):
	var new_pine = spawn_game_piece(game_piece, map_coordinates, true)
	new_pine.dig_tiles = plant_truffle(new_pine.cell.index)

#TODO: this does not take imnto account truffle blockers(other truffles, neraby trees)
func plant_truffle(pine_index):
	var potential_truffle_cells = $AggregateMap.astar.get_point_connections(pine_index)
	var new_truffle = truffle.instantiate()
	new_truffle.aggregate_map = $AggregateMap
	add_child(new_truffle)
	new_truffle.place_at_aggregate_index(potential_truffle_cells[randi_range(0, potential_truffle_cells.size() - 1)], false)
	return potential_truffle_cells

func spawn_foliage():
	var v3_array = []
	for c in $AggregateMap.aggregate_array:
		v3_array.append(c.local)
	$Foliage.spawn_foliage_on_array(v3_array)

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
