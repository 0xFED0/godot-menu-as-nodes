tool
extends MenuItemBase

class_name MenuSeparator

export(String) var text : = "" setget _set_text

func apply_to_menu(menu :PopupMenu) -> void:
	.apply_to_menu(menu)
	if is_instance_valid(_menu) and (idx != -1) and visible:
		_menu.set_item_as_separator(idx, true)
		_set_text(text)


func _set_text(value :String) -> void:
	text = value
	_set_item("text", value)