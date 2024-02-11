class_name WaitForWindow
extends Control

signal cancelled

const IDLING_ANIM = [".", "..", "...", "....", ".....", "....", "...", ".."]

@onready var timer = $IdlingTimer
@onready var title = $TopPanel/TopVBox/TitleLabel
@onready var idling = $TopPanel/TopVBox/IdlingLabel

var _anim_frame = 0


func wait_for(what: String):
	timer.start()
	title.text = what
	idling.text = IDLING_ANIM[_anim_frame]


func close():
	timer.stop()
	hide()


func _on_idling_timer_timeout():
	_anim_frame = wrapi(_anim_frame + 1, 0, len(IDLING_ANIM) - 1)
	idling.text = IDLING_ANIM[_anim_frame]


func _on_cancel_button_pressed():
	cancelled.emit()
