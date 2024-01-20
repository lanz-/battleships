extends RefCounted
class_name AITarget


const OFFSETS = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const OFFSETS2 = {
	true:  [Vector2i(-1, 0), Vector2i(1, 0)],
	false: [Vector2i(0, -1), Vector2i(0, 1)],
}

var _positions: Array[Vector2i] = []


func _init(pos: Vector2i):
	_positions.append(pos)


func at_pos(pos: Vector2i):
	for p in _positions:
		if (p - pos).length_squared() == 1:
			return true
		
	return false


func next_position(prev_shots):
	var candidates: Array[Vector2i] = []
	
	if _positions.size() == 1:
		for offset in OFFSETS:
			candidates.append(_positions[0] + offset)
	else:
		var diff = _positions[0] - _positions[-1]
		var horizontal = true
		if diff.x == 0:
			horizontal = false

		for position in _positions:
			for offset in OFFSETS2[horizontal]:
				candidates.append(position + offset)
	
	candidates = candidates.filter(func (p): return (p not in prev_shots) and (Game.is_in_field(p)))
	assert(candidates, "No candidates")
	
	return candidates.pick_random()

func add_point(pos: Vector2i):
	_positions.append(pos)
