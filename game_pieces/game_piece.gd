extends Node3D

class_name GamePiece
var aggregate_map
var cell
#TODO: Generic walk speed which can be overwritten in the ready of each game peice, or remove thisd once the speeds and tweens are sorted out
var walk_speed = 3
var walk_tween
var facing = 0 :
	set(new_value):
		facing = new_value
		if facing % 5 == 0:
			get_child(0).flip_h = true
		elif facing == 2 || facing == 3:
			get_child(0).flip_h = false

#TODO: rename alal of these i have no idea what is waht
func place_at(_cell):
	cell = _cell
	_cell.occupant = self
	position = cell.local

func get_facing_from_angle(y, x):
	return int((atan2(y, x)/PI+1)*3)

#these 2 funcitons might make more sene in aggregate_map
func place_at_map_coords(coords, disable_cell):
	var cell_index = aggregate_map.get_index_from_coords(coords)
	if cell_index != null: place_at_aggregate_index(cell_index, disable_cell)
	return cell_index

func place_at_aggregate_index(aggregate_index, disable_cell):
	place_at(aggregate_map.aggregate_array[aggregate_index])
	if disable_cell: aggregate_map.astar.set_point_disabled(aggregate_index)

func move_to_next_cell_from_facing():
		var next_index = get_index_next_tile_facing()
		if next_index != null && !aggregate_map.astar.is_point_disabled(next_index):
			walk_to_next_cell(aggregate_map.aggregate_array[next_index])
			aggregate_map.switch_occupant_cells(self, next_index)

func get_index_next_tile_facing():
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

func walk_to_next_cell(_cell):
#TODO: exception handling which probably shoudl not be here
	if _cell != null:
		walk_tween = create_tween()
		walk_tween.tween_property(self, "position", _cell.local, self.walk_speed)
		await walk_tween.finished

#does not wrok with occupied cells
func walk_to_far_cell(destination_cell):
	#TODO: exception handling which probably shoudl not be here
	if destination_cell != null:
		var path = aggregate_map.astar.get_point_path(cell.index, destination_cell.index)
		print(path)
		walk_tween = create_tween()
		for p in path:
			walk_tween.tween_property(self, "position", aggregate_map.grid_map.map_to_local(p), walk_speed)
		await walk_tween.finished
		aggregate_map.switch_occupant_cells(self, destination_cell.index)

#currently returns the start position as part of the results
#can probably be modified to return only the outer ring
func get_neighbors_in_range(range):
	var visited = [cell.index]
	for ring in range:
#this is inefficient becasue its going through every single index of visited each time rather than just checking the outer ring
		var neighbors = []
		for c in visited:
			neighbors.append_array(aggregate_map.astar.get_point_connections(c))
		for n in neighbors:
			if !aggregate_map.astar.is_point_disabled(n) && visited.find(n) == -1:
				visited.append(n)
	visited.pop_front()
	return visited
