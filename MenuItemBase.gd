tool
extends Node

class_name MenuItemBase

signal focused(item)
signal pressed(item)

signal visibility_changed(item)
signal moved(item)
signal unparented(item)

export(bool) var visible : = true setget _set_visible

var idx :int = -1
var id :int = -1

var _menu :PopupMenu

func _init():
	id = get_instance_id()


func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			var parent : = get_parent()
			if parent.has_method("add_menu_item"):
				parent.add_menu_item(self)
		NOTIFICATION_UNPARENTED:
			emit_signal("unparented", self)
			remove_from_menu(_menu)
		NOTIFICATION_MOVED_IN_PARENT:
			emit_signal("moved", self)


func add_to_menu(menu :PopupMenu) -> void:
	if not is_instance_valid(menu):
		return
	_menu = menu
	if _menu.get_item_index(id) != -1:
		return
	if not visible:
		return
	_menu.add_item("", id)
	idx = _menu.get_item_index(id)
	_menu.set_item_metadata(idx, get_parent().get_path_to(self))


func remove_from_menu(menu :PopupMenu) -> void:
	if not menu_is_valid():
		return
	var index = menu.get_item_index(id)
	if index != -1:
		menu.remove_item(index)
	if menu == _menu:
		idx = -1
		_menu = null


func apply_to_menu(menu :PopupMenu) -> void:
	if (_menu != menu):
		if menu_is_valid():
			remove_from_menu(_menu)
	add_to_menu(menu)
	if menu_is_valid():
		idx = _menu.get_item_index(id)
	else:
		idx = -1


func _set_visible(value :bool) -> void:
	visible = value
	if not visible:
		remove_from_menu(_menu)
	emit_signal("visibility_changed", self)


func _set_item(prop :String, value) -> void:
	if menu_is_valid() and visible:
		idx = _menu.get_item_index(id)
		var method : = "set_item_"+prop
		if (idx != -1) and _menu.has_method(method):
			_menu.call(method, idx, value)


func menu_is_valid() -> bool:
	return is_instance_valid(_menu) and (_menu is PopupMenu)

