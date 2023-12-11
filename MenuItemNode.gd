tool
extends MenuItemBase

class_name MenuItemNode

signal toggled(pressed, item)

enum CheckType {AS_BOX, AS_RADIO, NONE = -1}

export(String) var text : = ""                      setget _set_text
export(Texture) var icon :Texture                   setget _set_icon
export(CheckType) var checkable : = CheckType.NONE  setget _set_checkable
export(bool) var checked : = false                  setget _set_checked
export(bool) var disabled : = false                 setget _set_disabled

export(String) var value : = ""
export(String) var radio_group : = "default"        setget _set_radio_group
export(String, MULTILINE) var tooltip : = ""        setget _set_tooltip


func _init():
	connect("unparented", self, "_on_unparented")


func apply_to_menu(menu :PopupMenu) -> void:
	.apply_to_menu(menu)
	if menu_is_valid() and visible:
		for prop in ["text", "icon", "checked", "disabled", "tooltip", "checkable"]:
			call("_set_"+prop, get(prop))


func _on_unparented(item) -> void:
	item._unreg_radio()


func _toggle(item) -> void:
	item.checked = not item.checked
	emit_signal("toggled", checked, item)


func _set_text(value :String) -> void:
	text = value
	_set_item("text", value)

func _set_icon(value :Texture) -> void:
	icon = value
	_set_item("icon", value)

func _set_checked(value :bool) -> void:
	checked = value
	_set_item("checked", value)

func _set_disabled(value :bool) -> void:
	disabled = value
	_set_item("disabled", value)

func _set_tooltip(value :String) -> void:
	tooltip = value
	_set_item("tooltip", value)

func _set_checkable(value :int) -> void:
	checkable = value
	if (not menu_is_valid()) or (not visible):
		return
	_unreg_radio()
	if is_connected("pressed", self, "_toggle"):
		disconnect("pressed", self, "_toggle")
	idx = _menu.get_item_index(id)
	if idx == -1:
		return
	match checkable:
		CheckType.AS_BOX:
			_menu.set_item_as_checkable(idx, true)
			if not is_connected("pressed", self, "_toggle"):
				connect("pressed", self, "_toggle")
		CheckType.AS_RADIO:
			_menu.set_item_as_radio_checkable(idx, true)
			_reg_radio()
		CheckType.NONE:
			_menu.set_item_as_checkable(idx, false)
			_menu.set_item_as_radio_checkable(idx, false)


func _set_radio_group(value :String) -> void:
	_unreg_radio()
	radio_group = value
	_reg_radio()


func _reg_radio() -> void:
	var btn : = get_parent()
	if not is_instance_valid(btn):
		return
	if btn.has_method("add_to_radio_group"):
		btn.add_to_radio_group(self, radio_group)


func _unreg_radio() -> void:
	var btn : = get_parent()
	if not is_instance_valid(btn):
		return
	if btn.has_method("remove_from_radio_group"):
		btn.remove_from_radio_group(self, radio_group)


