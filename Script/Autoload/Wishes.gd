class_name Wishes
extends Node



var saved_vars := [
	"completed_wishes",
	"random_wish_limit",
	"completed_random_wishes",
	"wishes",
]


func load_finished() -> void:
	for wish in wishes:
		create_wish_vico(wish)
	print(completed_wishes)


signal wish_completed(type)

var wish_vico := preload("res://Hud/Wish/wish_vico.tscn")
var pending_wish_vico := preload("res://Hud/Wish/wish_pending.tscn")

var main_wish_container: VBoxContainer
var random_wish_container: VBoxContainer

var active_main_wishes := 0
var active_wish_types := []
var active_random_wishes := 0

var wishes := []
var completed_wishes := []
var completed_random_wishes := 0
var random_wish_limit := 0:
	set(val):
		random_wish_limit = val
		for i in val:
			find_new_random_wish()



func _ready() -> void:
	SaveManager.connect("load_finished", load_finished)



func close() -> void:
	wishes.clear()
	completed_wishes.clear()
	active_wish_types.clear()
	random_wish_limit = 0
	active_main_wishes = 0
	active_random_wishes = 0
	completed_random_wishes = 0




func new_game_start() -> void:
	start()


func loaded_game_start() -> void:
	
	start()


func start() -> void:
	if not is_wish_completed(Wish.Type.STUFF):
		create_wish_vico(await Wish.new(Wish.Type.STUFF))
		skip_STUFF_wish()
	else:
		find_new_main_wish()



func find_new_main_wish() -> void:
	if not gv.root_ready:
		await gv.root_ready_finished
	
	if not lv.purchased_every_unlocked_lored_once():
		await lv.purchased_every_lored_once
	if active_main_wishes > 0:
		return
	
	var wish = await Wish.new(select_main_wish())
	wishes.append(wish)
	create_wish_vico(wish)
	if wish.has_pair():
		for x in wish.pair:
			if not is_wish_begun_or_completed(x):
				var paired_wish = await Wish.new(x)
				wishes.append(paired_wish)
				create_wish_vico(paired_wish)


func select_main_wish() -> int:
	for type in Wish.Type.values():
		if type == Wish.Type.RANDOM:
			continue
		if not is_wish_begun_or_completed(type):
			return type
	return -1


func find_new_random_wish() -> void:
	if active_random_wishes < random_wish_limit:
		var wish = await Wish.new(Wish.Type.RANDOM)
		wishes.append(wish)
		create_wish_vico(wish)


func create_wish_vico(wish: Wish) -> void:
	if not gv.root_ready:
		await gv.root_ready_finished
	var my_pass = gv.password
	if not wish.ready_to_start:
		await wish.became_ready_to_start
		if my_pass != gv.password:
			return
		if wish.skip_wish:
			if active_main_wishes == 0:
				find_new_main_wish()
			return
	
	var container: VBoxContainer
	
	active_wish_types.append(wish.type)
	if wish.is_main_wish():
		container = main_wish_container
		active_main_wishes += 1
	else:
		container = random_wish_container
		active_random_wishes += 1
	
	var pending_vico = pending_wish_vico.instantiate()
	pending_vico.setup(wish)
	container.add_child(pending_vico)
	var pending_vico_index = pending_vico.get_index()
	
	await pending_vico.tree_exited
	if my_pass != gv.password or wish.killed:
		return
	
	var vico = wish_vico.instantiate()
	vico.setup(wish)
	container.add_child(vico)
	container.move_child(vico, pending_vico_index)
	
	start_new_wish_after_wish_completed(wish)


func start_new_wish_after_wish_completed(wish: Wish) -> void:
	var my_pass := gv.password
	await wish.just_ended
	if my_pass != gv.password:
		return
	wishes.erase(wish)
	active_wish_types.erase(wish.type)
	if wish.is_main_wish():
		complete_wish(wish.type)
		active_main_wishes -= 1
		if active_main_wishes == 0:
			find_new_main_wish()
	else:
		active_random_wishes -= 1
		if wish.turned_in:
			completed_random_wishes += 1
		find_new_random_wish()
	emit_signal("wish_completed", wish.type)



func skip_STUFF_wish() -> void:
	if is_wish_begun_or_completed(Wish.Type.FUEL):
		return
	var my_pass = gv.password
	await lv.get_lored(LORED.Type.COAL).leveled_up
	if my_pass != gv.password:
		return
	if active_main_wishes == 0 and not is_wish_begun_or_completed(Wish.Type.FUEL):
		create_wish_vico(await Wish.new(Wish.Type.FUEL))
		complete_wish(Wish.Type.STUFF)


func complete_wish(type: int) -> void:
	if not type in completed_wishes:
		completed_wishes.append(type)



# - Get

func is_wish_begun_or_completed(wish_type: int) -> bool:
	return wish_type in active_wish_types or is_wish_completed(wish_type)


func is_wish_completed(wish_type: int) -> bool:
	return wish_type in completed_wishes


func is_game_just_beginning() -> bool:
	return not Wish.Type.STUFF in completed_wishes and not lv.get_lored(LORED.Type.COAL).purchased
