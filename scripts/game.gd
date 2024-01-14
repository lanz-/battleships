extends Node


var _tween: Tween = null


func translate(pos: Vector3) -> Vector2i:
	return Vector2i(round(pos.x), round(pos.z))


func untranslate(pos: Vector2i) -> Vector3:
	return Vector3(pos.x, 0, pos.y)


func is_in_field(pos: Vector2i) -> bool:
	if (pos.x > 9) or (pos.x < 0):
		return false
			
	if (pos.y > 9) or (pos.y < 0):
		return false
	
	return true


func animate_move(obj, trans, time):
	if _tween:
		_tween.kill()

	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(obj, "transform", trans, time)
	
	return _tween
