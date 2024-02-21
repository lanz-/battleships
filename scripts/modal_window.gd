class_name ModalWindow
extends Control

enum {OK, CANCEL}

signal _close_modal(result)

@onready var ok_button = $Panel/TopVBox/ButtonHBox/OKButton
@onready var cancel_button = $Panel/TopVBox/ButtonHBox/CancelButton
@onready var edit = $Panel/TopVBox/LineEdit
@onready var private_check = $Panel/TopVBox/PrivateCheck
@onready var label = $Panel/TopVBox/Label


func _ready():
	edit.grab_focus()


func _on_ok_button_pressed():
	hide()
	_close_modal.emit(OK)


func _on_cancel_button_pressed():
	hide()
	_close_modal.emit(CANCEL)


func show_modal(label_text: String, input: bool, input_placeholder: String, check: bool):
	if check:
		private_check.show()
	else:
		private_check.hide()
	
	if input:
		edit.show()
		edit.placeholder_text = input_placeholder
	else:
		edit.hide()
	
	label.text = label_text

	return await _close_modal
