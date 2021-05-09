extends MarginContainer


onready var lock = get_node("Lock")

var upgrade_key: String

func init(_upgrade_key: String) -> void:
	
	upgrade_key = _upgrade_key
	get_node("Sprite").texture = gv.sprite[gv.up[upgrade_key].icon]
	lock.self_modulate = gv.up[upgrade_key].color
	
	update()

func update():
	
	if upgrade_key == "":
		return
	
	if gv.up[upgrade_key].have or gv.up[upgrade_key].requirements():
		lock.hide()
	else:
		lock.show()
