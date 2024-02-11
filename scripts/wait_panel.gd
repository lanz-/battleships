extends Panel

const ANIM_FRAMES = [".", "..", "...", "....", "....."]

@export var anim_frame: int = 0

@onready var label = $IdleLabel


func _ready():
	$Timer.start()


func _on_timer_timeout():
	anim_frame = wrapi(anim_frame + 1, 0, len(ANIM_FRAMES) - 1)
	label.text = ANIM_FRAMES[anim_frame]
