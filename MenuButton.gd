tool
extends MenuButton

signal radio_value_changed(radio_group, value)
signal radio_item_selected(item)
signal item_pressed(item)
signal item_focused(item)

export(bool) var hide_on_item_selection : = true           setget _set_hide_on_item_selection
export(bool) var hide_on_state_item_selection : = true     setget _set_hide_on_state_item_selection
export(bool) var hide_on_checkable_item_selection : = true setget _set_hide_on_checkable_item_selection


var _radio_groups :Dictionary = {}


func _ready():
	var menu : = get_popup()
	menu.connect("id_focused", self, "_on_id_focused")
	menu.connect("id_pressed", self, "_on_id_pressed")
	_refresh_items()


func add_menu_item(item :MenuItemBase) -> void:
	var menu : = get_popup()
	item.apply_to_menu(menu)
	if not item.is_connected("unparented", self, "_on_item_removed"):
		item.connect("unparented", self, "_on_item_removed")
	if not item.is_connected("moved", self, "_on_item_moved"):
		item.connect("moved", self, "_on_item_moved")
	if not item.is_connected("visibility_changed", self, "_on_item_visibility_changed"):
		item.connect("visibility_changed", self, "_on_item_visibility_changed")


func get_checked_values(with_radio :bool = false) -> Array:
	var list : = []
	var menu : = get_popup()
	for idx in range(menu.get_item_count()):
		if (not with_radio) and menu.is_item_radio_checkable(idx):
			continue
		if (menu.is_item_checkable(idx) or menu.is_item_radio_checkable(idx)) \
		and menu.is_item_checked(idx):
			var item : = _get_item(idx)
			if not is_instance_valid(item):
				continue
			var value : = _get_item_value(item)
			if not value.empty():
				list.append(value)
	return list


func get_radio_value(group_name :String = "default") -> String:
	var item = get_radio_selected(group_name)
	if is_instance_valid(item):
		return _get_item_value(item)
	return ""


func set_radio_value(value :String, group_name :String = "default") -> void:
	var grp : = _get_radio_group(group_name)
	for item in grp:
		if (item.value == value) or (item.text == value):
			_set_radio_option(item, group_name)


func get_radio_selected(group_name :String = "default") -> MenuItemBase:
	var grp : = _get_radio_group(group_name)
	for item in grp:
		if item.checked and item.visible:
			return item
	return null


func _get_radio_group(group_name :String = "default") -> Array:
	var grp :Array = []
	if (_radio_groups.keys().size() == 1) and (group_name == "default"):
		grp = _radio_groups.values()[0]
	else:
		grp = _radio_groups.get(group_name, [])
	return grp


func _on_item_removed(item :MenuItemBase) -> void:
	if item.is_connected("unparented", self, "_on_item_removed"):
		item.disconnect("unparented", self, "_on_item_removed")
	if item.is_connected("moved", self, "_on_item_moved"):
		item.disconnect("moved", self, "_on_item_moved")
	if item.is_connected("visibility_changed", self, "_on_item_visibility_changed"):
		item.disconnect("visibility_changed", self, "_on_item_visibility_changed")


func _on_item_moved(item :MenuItemBase) -> void:
	_refresh_items()

func _on_item_visibility_changed(item :MenuItemBase) -> void:
	_refresh_items()



func _on_id_focused(id :int) -> void:
	var item : = _get_item_by_id(id)
	if is_instance_valid(item):
		item.emit_signal("focused", item)
	emit_signal("item_focused", item)

func _on_id_pressed(id :int) -> void:
	var item : = _get_item_by_id(id)
	if is_instance_valid(item):
		item.emit_signal("pressed", item)
	emit_signal("item_pressed", item)


func _get_item_by_id(id :int) -> MenuItemBase:
	var menu : = get_popup()
	var idx = menu.get_item_index(id)
	return _get_item(idx)


func _get_item(idx :int) -> MenuItemBase:
	var menu : = get_popup()
	if (idx != -1) and (idx < menu.get_item_count()):
		var path = menu.get_item_metadata(idx)
		if path is NodePath:
			var item : = get_node_or_null(path) as MenuItemBase
			if is_instance_valid(item):
				item.idx = idx
			return item
	return null


func _refresh_items() -> void:
	var menu : = get_popup()
	menu.clear()
	for child in get_children():
		if not child is MenuItemBase:
			continue
		var item : = child as MenuItemBase
		add_menu_item(item)



func add_to_radio_group(item :MenuItemBase, group_name :String) -> void:
	if not is_instance_valid(item):
		return
	var grp :Array = _radio_groups.get(group_name, []) as Array
	grp.append(item)
	_radio_groups[group_name] = grp
	if not item.is_connected("pressed", self, "_on_radio_pressed"):
		item.connect("pressed", self, "_on_radio_pressed", [group_name])


func remove_from_radio_group(item :MenuItemBase, group_name :String) -> void:
	if not is_instance_valid(item):
		return
	var grp :Array = _radio_groups.get(group_name, []) as Array
	grp.erase(item)
	if grp.empty():
		_radio_groups.erase(group_name)
	if item.is_connected("pressed", self, "_on_radio_pressed"):
		item.disconnect("pressed", self, "_on_radio_pressed")


var _lock_radio : = false # to prevent recursion

func _set_radio_option(item :MenuItemBase, group_name :String) -> void:
	if _lock_radio:
		return
	_lock_radio = true
	for radio in _radio_groups[group_name]:
		if "checked" in radio:
			radio.checked = false
	if "checked" in item:
		item.checked = true
	emit_signal("radio_value_changed", group_name, _get_item_value(item))
	_lock_radio = false


func _on_radio_pressed(item :MenuItemBase, group_name :String) -> void:
	if not is_instance_valid(item):
		return
	_set_radio_option(item, group_name)
	emit_signal("radio_item_selected", item)
	pass


func _get_item_value(item) -> String:
	var value = item.get("value")
	if (not value is String) or (value.empty()):
		value = item.get("text")
	if value is String:
		return value as String
	return ""


func _set_hide_on_item_selection(value : bool) -> void:
	get_popup().hide_on_item_selection = value


func _set_hide_on_state_item_selection(value : bool) -> void:
	get_popup().hide_on_state_item_selection = value


func _set_hide_on_checkable_item_selection(value : bool) -> void:
	get_popup().hide_on_checkable_item_selection = value