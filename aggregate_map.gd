extends Node

var aggregate_array = []
var astar = HexStar.new()
var grid_map
var map
class HexStar:
	extends AStar3D
	func _compute_cost(from_id, to_id):
		return abs(from_id - to_id)
	func _estimate_cost(from_id, to_id):
		return min(0, abs(from_id - to_id) - 1)

func ready_aggregate_array(_grid_map):
	grid_map = _grid_map
	var coord_array = grid_map.get_used_cells()
	aggregate_array.resize(coord_array.size())
	for c in coord_array:
		var unified_index = astar.get_available_point_id()
		astar.add_point(unified_index, c, 0.5)
		aggregate_array[unified_index] = {"index": unified_index, "map": c, "local": grid_map.map_to_local(c), "occupant": null}
		for p in astar.get_point_ids():
			var point_position = astar.get_point_position(p)
			if (
				(point_position.x == c.x && (point_position.z - 2 == c.z || point_position.z + 2 == c.z))
				|| ((point_position.z - 1 == c.z || point_position.z + 1 == c.z) && (point_position.x - 1 == c.x || point_position.x + 1 == c.x))
			):
				astar.connect_points(astar.get_closest_point(c), p)

func _set_cell(_index, _grid_map, _grid_map_local, _occupant):
	var new_cell = {
		"index": _index,
		"grid_map": _grid_map,
		"grid_map_local": _grid_map_local,
		"occupant": _occupant
		}

#TODO: determine which funcituon should be assigning the current cell to the participant, it may not be this one
func switch_occupant_cells(occupant, to_index):
	astar.set_point_disabled(occupant.cell.index, false)
	occupant.cell.occupant = null
	astar.set_point_disabled(to_index)
	aggregate_array[to_index].occupant = occupant
	occupant.cell = aggregate_array[to_index]

func get_index_from_coords(coords):
#this is using filter becasue custom search (custom_first) do not yet exist in godot, please replace if they are implemented
	var array_of_one = aggregate_array.filter(func(cell): return cell.map == coords)
	return array_of_one[0].index if array_of_one.size() > 0 else null
