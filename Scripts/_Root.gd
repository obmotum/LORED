class_name _root
extends Node2D


const SAVE := {
	MAIN = "user://save.lored",
	NEW = "user://new_save.lored",
	OLD = "user://last_save.lored"
}

const prefab := {
	tasks = preload("res://Prefabs/task/tasks.tscn"),
	
	tip_autobuyer = preload("res://Prefabs/tooltip/autobuyer.tscn"),
	
	"dtext": preload("res://Prefabs/dtext.tscn"),
	"confirmation popup": preload("res://Prefabs/lored_buy.tscn"),
	"menu": preload("res://Prefabs/menu/menu.tscn"),
}


var FPS = 0.04


var content := {}
var content_tasks := {}
var instances := {}
var upgrade_dtexts := {}

var save_fps = 0.0
var times_game_loaded = 0
var loredalert = ""

var cur_clock = OS.get_unix_time()
var last_clock = OS.get_unix_time()
var cur_session = 0
var time_fps = 0.0

var menu_window = 0

const gnLOREDs = "m/v/LORED List"
const gntaq = "m/v/bot/h/taq"
const gnquest = gntaq + "/quest"
const gnLB = "m/v/top/h/Limit Break"
const gnupcon = "m/up_container"
const gnalert = "misc/tabs/v/upgrades/alert"
const gn_patch = "m/Patch Notes"

var task_awaiting := "no"




var hax = 1 # 1 for normal

func _ready():
	
	OS.set_low_processor_usage_mode(true)
	
	gv.connect("quest reward", self, "quest reward")
	
	# menu and stats
	if true:
	
		if "desktop" in gv.PLATFORM:
			gv.menu.option["FPS"] = 7
		else:
			gv.menu.option["FPS"] = 5
	
	get_node(gnLOREDs).setup()
	get_node("m/v/top/h/resources").setup()
	
	for x in gv.g:
		
		get_node(gnLOREDs).cont[x].start_all()
	
	get_tree().get_root().connect("size_changed", self, "r_window_size_changed")
	
	
	game_start(e_load())

func game_start(successful_load: bool) -> void:
	
	#gv.menu.option["task auto"] = false
	
	if not successful_load:
		gv.r["stone"] = Big.new(5)
		get_node("m/Patch Notes").hide()
	else:
		for x in gv.g:
			if gv.g[x].unlocked:
				continue
			if gv.g[x].active:
				gv.g[x].unlocked = true
	
	print("highest run: ", gv.stats.highest_run)
	print("most_resources_gained: ", gv.stats.most_resources_gained.toString())
	
	# work
	if true:
		
		# upgrades
		if true:
			
			for x in gv.up:
				if gv.up[x].requires.size() == 0:
					gv.up[x].unlocked = true
			
			gv.check_for_the_s2_shit()
			
			gv.up["ROUTINE"].have = false
		
		# loreds
		if true:
			
			for x in gv.g:
				
				#get_node(gnLOREDs).cont[x].start_all()
				get_node(gnLOREDs).cont[x].r_update_halt(gv.g[x].halt)
				get_node(gnLOREDs).cont[x].r_update_hold(gv.g[x].hold)
		
		w_aa()
		
		# taq
		if true:
			
			for x in [gv.Quest.WITCH, gv.Quest.HUNT, gv.Quest.BLOOD, gv.Quest.NECRO]:
				gv.quest[x].update()
	
	# ref
	if true:
		
		# lored
		if true:
			
			for x in gv.g:
				
				get_node(gnLOREDs).cont[x].r_autobuy()
		
		# menu and tab shit
		if true:
			
			menu_window = prefab["menu"].instance()
			$misc.add_child(menu_window)
			menu_window.init(gv.menu.option)
		
		# b_upgrade_tab
		if true:
			
			get_node(gnupcon).init()
			afford()
		
		check_all_quests()
		
		remove_surplus_tasks()
		
		# map
		$map.init()
	
	# hax
	if true:
		
#		if gv.test_s3:
#			unlock_tab("3")
		
		if gv.s3_time:
			unlock_tab("1")
			unlock_tab("2")
			unlock_tab("3")
			for x in gv.g:
				if gv.g[x].stage == "3":
					gv.g[x].unlock()
			unlock_tab("s1n")
			get_node("Button").show()
			unlock_tab("s3n")
			gv.r["flayed corpse"].a(10)
	
	# tasks
	if true:
		
		if not get_node(gnLOREDs).cont["water"].visible and gv.quest[gv.Quest.A_NEW_LEAF].complete:
			get_node(gnLOREDs).cont["water"].show()
			get_node(gnLOREDs).cont["seed"].show()
			get_node(gnLOREDs).cont["tree"].show()
		
		if gv.quest[gv.Quest.SPREAD].complete and not gv.quest[gv.Quest.CONSUME].complete:
			if gv.r["malig"].less(10) and not gv.g["tar"].active:
				gv.r["malig"] = Big.new(10)
		
		for x in gv.quest:
			
			if x.complete or x.selectable:
				continue
			
			taq.new_quest(x)
			get_node(gnquest).show()
			break
		
		if taq.cur_quest == -1:
			get_node(gnquest).hide()
		
		if "tasks" in content_tasks.keys():
			content_tasks["tasks"].hit_max_tasks()


func _physics_process(delta):
	
	#gv.r["malig"] = Big.new("5e8")
	#gv.g["coal"].r = Big.new("1e3")
	
	# work
	if true:
		
		save_fps += delta
		time_fps += delta
		
		if save_fps > 10:
			save_fps -= 10
			if hax <= 1 and not gv.test_s3:
				e_save()
		
		if time_fps > 1:
			time_fps -= 1
			cur_clock = OS.get_unix_time()
			cur_session += 1

func _input(ev):
	
	if ev.is_class("InputEventMouseMotion"):
		return
	
	if ev.is_action_pressed("ui_cancel"):
		b_tabkey(KEY_ESCAPE)
		return
	
	if Input.is_key_pressed(KEY_1):
		b_tabkey(KEY_1)
		return
	
	if Input.is_key_pressed(KEY_2):
		b_tabkey(KEY_2)
		return
	
	if Input.is_key_pressed(KEY_3):
		b_tabkey(KEY_3)
		return
	
	if Input.is_key_pressed(KEY_4):
		b_tabkey(KEY_4)
		return
	
	
	if ev.is_action_pressed("ui_upgrade_menu"):
		
		if get_node(gnupcon).visible:
			
			if get_node(gnupcon).get_node("v").visible:
				get_node("global_tip")._call("no")
				get_node(gnupcon).go_back()
			else:
				get_node(gnupcon).hide()
				
			
			return
		
		else:
			b_close_menu()
			show_alert_guy(false)
			get_node(gnupcon).show()
			return
	
	
	
	if Input.is_key_pressed(KEY_Q):
		b_tabkey(KEY_Q)
		return

	if Input.is_key_pressed(KEY_W):
		b_tabkey(KEY_W)
		return

	if Input.is_key_pressed(KEY_E):
		b_tabkey(KEY_E)
		return

	if Input.is_key_pressed(KEY_R):
		b_tabkey(KEY_R)
		return

	if Input.is_key_pressed(KEY_A):
		b_tabkey(KEY_A)
		return
	
	if Input.is_key_pressed(KEY_KP_ENTER) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER):
		
		if not "tasks" in content_tasks.keys():
			return
		
		if content_tasks["tasks"].ready_task_count > 0:
			var _content = []
			for x in taq.task:
				_content.append(taq.task[x].code)
			if $global_tip.tip_filled:
				if "taq" in $global_tip.tip.type:
					$global_tip._call("no")
			for x in _content:
				if x in content_tasks["tasks"].content.keys():
					if content_tasks["tasks"].content[x].get_node("tp").value >= 100:
						content_tasks["tasks"].content[x]._on_task_pressed()
			return
		if taq.cur_quest != -1:
			if taq.content.get_node("done").visible:
				taq.content.b_end_task()
				return
		return
	
	if Input.is_key_pressed(KEY_EQUAL):
		b_tabkey(KEY_ESCAPE)
		return
func _notification(ev):
	if ev == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		
		get_node("global_tip")._call("no")
		
		if OS.get_unix_time() - cur_clock <= 1: return
		var clock_dif = OS.get_unix_time() - last_clock
		if clock_dif <= 1: return
		
		w_total_per_sec(clock_dif)
	elif ev == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		last_clock = OS.get_unix_time()
func _on_menu_button_button_down():
	$map.status = "no"
func _on_menu_button_pressed():
	b_tabkey(KEY_ESCAPE)

func _on_upgrades_pressed() -> void:
	
	# duplicate code, also found under _input -> ui_upgrades or whatever
	
	if get_node(gnupcon).visible:
		
		get_node(gnupcon).go_back()
		get_node(gnupcon).hide()
		
		return
	
	get_node(gnupcon).show()
	get_node(gnalert).hide()


func _on_s1_pressed() -> void:
	b_tabkey(KEY_1)

func _on_s2_pressed() -> void:
	b_tabkey(KEY_2)

func _on_s3_pressed() -> void:
	b_tabkey(KEY_3)


# working funcs
func w_aa():
	for x in gv.g:
		gv.g[x].sync()


func w_total_per_sec(clock_dif : float) -> void:
	
	if "no" in gv.menu.f:
		return
	
	var gained := {}
	var consumed := {}
	var num_of_consumers := {}
	var gain_reduction := {}
	var consumed_reduction := {}
	
	for x in gv.g:
		gain_reduction[x] = Big.new()
		consumed_reduction[x] = Big.new()
		consumed[x] = Big.new(0)
		gained[x] = Big.new(0)
		num_of_consumers[x] = 0
	
	# set gained and consumed for each lored
	for x in gv.g:
		
		if not gv.g[x].active:
			continue
		
		var fuel_gained := true
		if "bur " in gv.g[x].type and not gv.g["coal"].active():
			fuel_gained = false
		if "ele " in gv.g[x].type and not gv.g["jo"].active():
			fuel_gained = false
		
		# coal storage / battery gain
		if fuel_gained:
			
			var fuel_gain = Big.new(gv.g[x].fc.t).m(clock_dif)
			
			gv.g[x].f.f = Big.new(Big.min(Big.new(gv.g[x].f.f).a(fuel_gain), gv.g[x].f.t))
			gv.g[x].sync()
		
		if gv.g[x].halt:
			continue
		
		var inactive_input := false
		for v in gv.g[x].b:
			if not gv.g[v].active() or gv.g[v].hold:
				inactive_input = true
				break
		if inactive_input: continue
		
		# fuel consumption
		if true:
			
			if "ye" in gv.menu.f:
				if "bur " in gv.g[x].type:
					consumed["coal"].a(Big.new(gv.g[x].fc.t).m(clock_dif))
				if "ele " in gv.g[x].type:
					consumed["jo"].a(Big.new(gv.g[x].fc.t).m(clock_dif))
			
			if "s1" in gv.g[x].type and "s1" in gv.menu.f: continue
			elif "s2" in gv.g[x].type and "s2" in gv.menu.f: continue
		
		var net = gv.g[x].net(true)
		
		# gained
		var _gained = Big.new(net[0]).m(clock_dif)
		gained[x] = Big.new(_gained)
		gv.stats.r_gained[x].a(_gained)
		var per_sec = Big.new(gv.g[x].d.t).d(gv.g[x].speed.t).m(clock_dif)
		
		# consumed
		for v in gv.g[x].b:
			# by this point, every lored here will be active. see 2 sections up
			consumed[v] = Big.new(per_sec).m(gv.g[x].b[v].t)
			num_of_consumers[v] += 1
	
	# unique gained reductions
	if true:
		
		# routine
		while true:
			
			if gained["malig"].less(gv.up["ROUTINE"].cost["malig"].t):
				break
			var excess = Big.new(gained["malig"]).s(gv.up["ROUTINE"].cost["malig"].t)
			excess.m(0.1)
			
			gained["malig"] = Big.new(gv.up["ROUTINE"].cost["malig"].t).a(excess)
			
			break
	
	# reduce gained if either fuel or input is insufficient. if gained is reduced, reduce consumed of input.
	if true:
		
		var coal_efficiency : Big = Big.new(gained["coal"])
		if consumed["coal"].equal(0):
			coal_efficiency = Big.new()
		else:
			coal_efficiency.d(consumed["coal"])
		if coal_efficiency.greater(1) or Big.new(gv.r["coal"]).s(consumed["coal"]).greater(gv.g["coal"].d.t):
			coal_efficiency = Big.new()
		
		var jo_efficiency : Big = Big.new(gained["jo"])
		if consumed["jo"].equal(0):
			jo_efficiency = Big.new()
		else:
			jo_efficiency.d(consumed["jo"])
		if jo_efficiency.greater(1) or Big.new(gv.r["jo"]).s(consumed["jo"]).greater(gv.g["jo"].d.t):
			jo_efficiency = Big.new()
		
		print("WELCOME BACK!\n\nTime away: ", gv.big_to_time(Big.new(clock_dif)))
		print("coal/joule efficiency: ", coal_efficiency.toString(), "/", jo_efficiency.toString(), "\n")
		
		for x in gv.g:
			
			if not gv.g[x].active: continue
			
			if "bur " in gv.g[x].type: gain_reduction[x].m(coal_efficiency)
			if "ele " in gv.g[x].type: gain_reduction[x].m(jo_efficiency)
			
			if consumed[x].less(gained[x]): continue
			if Big.new(gv.r[x]).s(consumed[x]).greater(0): continue
			
			if "bur " in gv.g[x].type: consumed_reduction[x].m(coal_efficiency)
			if "ele " in gv.g[x].type: consumed_reduction[x].m(jo_efficiency)
			
			if num_of_consumers[x] == 0: num_of_consumers[x] = 1
			
			if consumed[x].equal(0): consumed[x] = Big.new()
			
			
			var uh = Big.new(gained[x].percent(consumed[x])).d(num_of_consumers[x])
			
			for v in gv.g[x].used_by:
				
				if not gv.g[v].active: continue
				gain_reduction[v].m(uh)
			
			consumed_reduction[x].m(uh)
		
		for x in gain_reduction:
			
			if gain_reduction[x].equal(1): continue
			
			#prrint(":( alert! - ", x, " gains x", gain_reduction[x].toString(), " :: ", gained[x].toString(), " -> ", Big.new(gained[x]).m(gain_reduction[x]).toString())
			gained[x].m(gain_reduction[x])
		
		# quest
		if taq.cur_quest != -1:
			for x in gv.g:
				for z in taq.quest.step:
					if not "produced" in z:
						continue
					if gv.g[x].name in z or z == "Combined resources produced" or (z == "Combined Stage 2 resources produced" and "s2" in gv.g[x].type):
						var a = Big.new(taq.quest.step[z].f).a(gained[x])
						taq.quest.step[z].f = Big.new(Big.min(a, taq.quest.step[z].b))
		
		for x in consumed_reduction:
			
			if consumed_reduction[x].equal(1): continue
			
			print(x, " consumed x", consumed_reduction[x].toString(), " :: ", consumed[x].toString(), " -> ", Big.new(consumed[x]).m(consumed_reduction[x]).toString())
			consumed[x].m(consumed_reduction[x])
			gained[x] = Big.new(0)
	
	# task stuff
	for x in taq.task:
		for v in taq.task[x].step:
			
			if not "produced" in v:
				continue
			
			if "resources produced" in v:
				for b in gained:
					if "Combined resources produced" == v and "s1" in gv.g[b].type:
						var yikes = Big.new(Big.min(Big.new(taq.task[x].step[v].f).a(gained[b]), taq.task[x].step[v].b))
						taq.task[x].step[v].f = Big.new(yikes)
					elif "Combined Stage 2 resources produced" == v and "s2" in gv.g[b].type:
						var yikes = Big.new(Big.min(Big.new(taq.task[x].step[v].f).a(gained[b]), taq.task[x].step[v].b))
						taq.task[x].step[v].f = Big.new(yikes)
				continue
			
			var f = v.split(" produced")[0].to_lower()
			var ya = Big.new(Big.min(Big.new(taq.task[x].step[v].f).a(gained[f]), taq.task[x].step[v].b))
			taq.task[x].step[v].f = Big.new(ya)
	
	# subtract consumed from gained
	for x in gv.g:
		
		if not gv.g[x].active:
			continue
		
		
		if consumed[x].greater(gained[x]):
			consumed[x].s(gained[x])
			if consumed[x].greater(gv.r[x]):
				gv.r[x] = Big.new(0)
			else:
				gv.r[x].s(consumed[x])
			print(x, ": -", consumed[x].toString(), " (", gained[x].toString(), " gained, ", consumed[x].toString(), " drained)")
		else:
			gained[x].s(consumed[x])
			print(x, ": +", consumed[x].toString(), " (", gained[x].toString(), " gained, ", consumed[x].toString(), " drained)")
			gv.r[x].a(gained[x])
		
		if x != "coal": continue
		if gv.r[x].less(gv.g[x].d.t):
			gv.r[x] = Big.new(gv.g[x].d.t)
	
	for x in gv.g:
		if gv.r[x].less(0):#isNegative():
			gv.r[x] = Big.new(0)
	
	# upgrade-only stuff
	if true:
		
		if gv.up["I DRINK YOUR MILKSHAKE"].active():
			var num_of_burner_loreds := 0
			for x in gv.g:
				if not gv.g[x].active: continue
				if not "bur " in gv.g[x].type: continue
				num_of_burner_loreds += 1
			var gay = Big.new(num_of_burner_loreds).m(clock_dif).m(0.0001)
			gv.up["I DRINK YOUR MILKSHAKE"].effects[0].effect.a.a(gay)


func afford():
	
	while true:
		
		var t = Timer.new()
		add_child(t)
		t.start(1)
		yield(t, "timeout")
		t.queue_free()
		
		if not gv.up["we were so close, now you don't even think about me"].active():
			for x in gv.stats.up_list["unowned s1n"]:
				afford_check(x)
		
		if gv.stats.tabs_unlocked["2"]:
			if not gv.up["Now That's What I'm Talkin About, YeeeeeeaaaaaaaAAAAAAGGGGGHHH"].active():
				for x in gv.stats.up_list["unowned s2n"]:
					afford_check(x)



func afford_check(x: String):
	
	if gv.up[x].have:
		get_node(gnupcon).alert(false, x)
		return
	
	for u in gv.up[x].requires:
		if not gv.up[u].have:
			return
	
	if not gv.up[x].cost_check():
		get_node(gnupcon).alert(false, x)
		return
	
	if get_node(gnupcon).cont[x].already_displayed_alert_guy:
		return
	
	# pass!
	
	show_alert_guy()
	#get_node(gnupcon).cont[x].already_displayed_alert_guy = true
	get_node(gnupcon).alert(true, x)

func show_alert_guy(show := true):
	
	if show:
		if get_node(gnupcon).visible:
			return
	
	get_node(gnalert).visible = show


func quest_reward(type_key: int, other_key: String) -> void:
	
	match type_key:
		
		
		gv.QuestReward.OTHER:
			
			match other_key:
				
				gv.Quest.UPGRADES:
					
					if not "tasks" in content_tasks.keys():
						var _tasks := []
						for v in taq.task:
							_tasks.append(taq.task[v])
						content_tasks["tasks"] = prefab.tasks.instance()
						get_node(gntaq).add_child(content_tasks["tasks"])
						get_node(gntaq).move_child(get_node(gnquest), 2)
						content_tasks["tasks"].init(_tasks)
				
				gv.Quest.SPIKE:
					
					if "tasks" in content_tasks.keys():
						content_tasks["tasks"].get_node("HBoxContainer/auto").show()
						content_tasks["tasks"].get_node("HBoxContainer/auto/AnimatedSprite").show()
						content_tasks["tasks"].get_node("HBoxContainer/auto/Label").hide()
						for v in content_tasks["tasks"].content:
							if content_tasks["tasks"].content[v].get_node("tp").value >= 100:
								content_tasks["tasks"].content[v]._on_task_pressed()
		
		gv.QuestReward.STAGE:
			unlock_tab(other_key)
		gv.QuestReward.UPGRADE_MENU:
			unlock_tab(other_key, true)

func check_all_quests():
	
	for q in gv.quest:
		if q.complete:
			q.turn_in()

#func w_task_effects(which := []) -> void:
#
#	if which == []:
#		for x in gv.quest:
#			which.append(x)
#
#	for x in which:
#
#		if not quests[x].complete:
#			continue
#		if quests[x].effect_loaded:
#			continue
#		quests[x].effect_loaded = true
#
#		for v in quests[x].reward:
#			if "New LORED: " in v:
#				var key = v.split("New LORED: ")[1]
#				gv.g[key].unlocked = true
#				get_node(gnLOREDs).cont[key].show()
#			if "Upgrade the %s LORED!" == v:
#				var key = x.to_lower()
#				gv.g[key].manager.buy(false)
#
#		if "Max tasks +1" in quests[x].reward.keys():
#			taq.max_tasks += 1
#
#		match x:
#			"Spike":
#				if "tasks" in content_tasks.keys():
#					content_tasks["tasks"].get_node("HBoxContainer/auto").show()
#					content_tasks["tasks"].get_node("HBoxContainer/auto/AnimatedSprite").show()
#					content_tasks["tasks"].get_node("HBoxContainer/auto/Label").hide()
#					for v in content_tasks["tasks"].content:
#						if content_tasks["tasks"].content[v].get_node("tp").value >= 100:
#							content_tasks["tasks"].content[v]._on_task_pressed()
#			"Upgrades!":
#				if not "tasks" in content_tasks.keys():
#					var _tasks := []
#					for v in taq.task:
#						_tasks.append(taq.task[v])
#					content_tasks["tasks"] = prefab.tasks.instance()
#					get_node(gntaq).add_child(content_tasks["tasks"])
#					get_node(gntaq).move_child(get_node(gnquest), 2)
#					content_tasks["tasks"].init(_tasks)
#			"A New Leaf":
#				unlock_tab("1")
#				unlock_tab("2")
#				get_node("misc/menu").w_display_run(quests[x].complete)
#			"Welcome to LORED":
#				unlock_tab("s1n")
#			"Consume":
#				unlock_tab("s1m")
#			"The Heart of Things":
#				gv.g["tum"].unlocked = true
#				if get_node(gnLOREDs).cont["seed"].b_ubu_s2n_check():
#					unlock_tab("s2n")
#			"Cancer Lord":
#				unlock_tab("s2m")
#			"A Dark Discovery":
#				unlock_tab("s3n")
#				gv.g["hunt"].unlock()
#				gv.g["witch"].unlock()





func remove_surplus_tasks():
	
	if taq.cur_tasks <= taq.max_tasks:
		return
	
	print(taq.cur_tasks, " tasks; the maximum is ", taq.max_tasks, ". Deleting some.")
	
	for x in content_tasks["tasks"].content.keys():
		
		if taq.cur_tasks == taq.max_tasks:
			break
		content_tasks["tasks"].content[x].kill_yourself()


func activate_lb_effects():
	
	if gv.up["Limit Break"].active():
		get_node(gnLB).r_limit_break()
		get_node(gnLB).r_set_colors()
		get_node(gnLB).show()
	
	else:
		
		get_node(gnLB).hide()



func r_window_size_changed() -> void:
	
	var win :Vector2= get_viewport_rect().size
	var node = 0
	
	get_node("m").rect_size = win
	
	get_node(gnupcon).get_node("v/upgrades").scroll_vertical = 0
	
	# menu
	if true:
		node = menu_window.get_node("ScrollContainer")
		menu_window.position = Vector2(int(win.x / 2 - node.rect_size.x / 2), int(win.y / 2 - node.rect_size.y / 2))
		$map.pos["menu"] = menu_window.position




func reset(reset_type: int, manual := true) -> void:
	
	reset_stats(reset_type)
	
	reset_upgrades(reset_type, manual)
	reset_resources(reset_type)
	reset_loreds(reset_type)
	activate_refundable_upgrades(reset_type)
	reset_tasks(reset_type)
	reset_limit_break(reset_type)
	
	# ref
	if true:
		
		if reset_type == 0:
			unlock_tab("1", false)
			unlock_tab("2", false)
			unlock_tab("3", false)
			unlock_tab("4", false)
			unlock_tab("s1n", false)
			unlock_tab("s1m", false)
			unlock_tab("s2n", false)
			unlock_tab("s2m", false)
			unlock_tab("s3n", false)
			get_node(gnupcon).clear_alerts()
		
		if reset_type >= 2:
			unlock_tab("s2n", false)
		
		for x in gv.g:
			get_node(gnLOREDs).cont[x].r_autobuy()
	
	if manual:
		b_tabkey(KEY_1)
	
	gv.menu.f = "ye"
	
	get_node(gnupcon).sync()
	
	if reset_type == 0:
		get_tree().reload_current_scene()
	

func reset_stats(reset_type: int):
	
	if reset_type == 0:
		
		# full reset!

		for x in gv.stats.run.size():
			gv.stats.run[x] = 1
			gv.stats.last_run_dur[x] = 0
			gv.stats.last_reset_clock[x] = OS.get_unix_time()
		
		gv.stats.most_resources_gained = Big.new(0)
		gv.stats.highest_run = 1
		
		return
	
	
	if reset_type > gv.stats.highest_run:
		gv.stats.highest_run = reset_type
		gv.stats.most_resources_gained = Big.new(0)
	
	if reset_type == gv.stats.highest_run:
		
		var gg = "malig"
		match reset_type:
			2: gg = "tum"
		
		if gv.stats.most_resources_gained.less(gv.stats.r_gained[gg]):
			gv.stats.most_resources_gained = Big.new(gv.stats.r_gained[gg])
			print("new highest resources gained: ", gv.stats.most_resources_gained.toString(), " (", gg, ")")
	
	for x in reset_type:
		
		gv.stats.run[x] += 1
		gv.stats.last_run_dur[x] = OS.get_unix_time() - gv.stats.last_reset_clock[x]
		gv.stats.last_reset_clock[x] = OS.get_unix_time()

func reset_upgrades(reset_type: int, manual: bool):
	
	# full reset
	if reset_type == 0:
		
		gv.s2_upgrades_may_be_autobought = false
		
		for x in gv.up:
			
			gv.up[x].refundable = false
			
			if not gv.up[x].have:
				continue
			
			gv.up[x].reset()
			
			get_node(gnupcon).cont[x].r_update()
		
		# upgrade tabs are locked in the reset func
		
		return
	
	# for s2 upgrade autobuyers; won't buy if loreds in own_list aren't owned
	
	# routine reset; don't reset every upgrade
	
	if reset_type >= 2:
		
		gv.s2_upgrades_may_be_autobought = false
		
		for x in gv.stats.up_list["s2"]:
			reset_upgrade(x, reset_type, manual)
	
	if reset_type >= 1:
		for x in gv.stats.up_list["s1"]:
			reset_upgrade(x, reset_type, manual)
	
	for x in gv.up:
		if not x in get_node(gnupcon).cont.keys():
			continue
		get_node(gnupcon).cont[x].r_update_icon()

func reset_upgrade(x: String, reset_type: int, manual: bool):
	
	if not gv.up[x].have:
		return
	
	if x in ["Limit Break"]:
		gv.reset_lb()
	
	if int(gv.up[x].type[1]) == reset_type and not gv.up[x].normal:
		
		# ex: if Chemoing, and up[x] is type s2m, partial_reset() it
		
		if x in ["IT'S GROWIN ON ME", "I DRINK YOUR MILKSHAKE"]:
			if not manual:
				return
		
		gv.up[x].partial_reset()
		
		if manual and x == "PROCEDURE":
			get_node(gnupcon).cont["ROUTINE"].routine_shit()
		
		return
	
	# send reset_type, which means
	# if another upgrade has caused the upgrade in question (x) to perist through reset, it will return here immediately
	if gv.up[x].reset(reset_type):
		
		get_node(gnupcon).cont[x].r_update()
		get_node(gnupcon).cont[x].upgrade_effects(false, false)
		get_node(gnupcon).cont[x].set_physics_process(true)
		
		# ref
		get_node(gnupcon).cont[x].r_update()
		gv.stats.upgrades_owned[gv.up[x].type.split(" ", true, 1)[0]] -= 1

func reset_resources(reset_type: int):
	
	if reset_type == 0:
		
		for x in gv.g:
			
			gv.r[x] = Big.new(0)
		
		gv.r["stone"].a(5)
		
		return
	
	var lb = Big.new(gv.up["Limit Break"].effects[0].effect.t)
	
	# s1
	if reset_type >= 1:
		
		if (reset_type == 1 and not gv.up["CONDUCT"].active()) or reset_type != 1:
			
			for x in gv.stats.g_list["s1"]:
				
				if x == "malig" and reset_type == 1:
					continue
				
				gv.r[x] = Big.new(0)
		
		gv.r["stone"].a(Big.new(lb).m(5.0))
		gv.r["iron"].a(Big.new(lb).m(10.0))
		gv.r["cop"].a(Big.new(lb).m(10.0))
		gv.r["malig"] = Big.new(Big.max(gv.r["malig"], 10))
		if gv.up["FOOD TRUCKS"].active(true):
			gv.r["cop"].a(Big.new(lb).m(100.0))
			gv.r["iron"].a(Big.new(lb).m(100.0))
	
	# s2
	if reset_type >= 2:
		
		for x in gv.stats.g_list["s2"]:
			
			if x == "tum" and reset_type == 2:
				continue
			
			gv.r[x] = Big.new(0)
		
		gv.r["wood"] = Big.new(lb).m(200)
		gv.r["soil"] = Big.new(lb).m(50)
		gv.r["tree"] = Big.new(lb).m(5)
		gv.r["steel"] = Big.new(lb).m(200)
		gv.r["hard"] = Big.new(lb).m(200)
		gv.r["wire"] = Big.new(lb).m(200)
		gv.r["glass"] = Big.new(lb).m(500)
		gv.r["axe"] = Big.new(lb).m(50)

func reset_loreds(reset_type: int):
	
	if reset_type == 0:
		for x in gv.g:
			gv.g[x].reset()
			if not (x == "coal" or x == "stone"):
				get_node(gnLOREDs).cont[x].hide()
		return
	
	if gv.up["dust"].active():
		if reset_type == 1:
			return
	
	for x in gv.g:
		
		if int(gv.g[x].type[1]) > reset_type:
			continue
		
		get_node(gnLOREDs).cont[x].get_node("h/h/animation/AnimatedSprite").animation = "ww"
		get_node(gnLOREDs).cont[x].get_node("h/h/animation/AnimatedSprite").playing = true
		
		if x == "coal" and gv.up["aw <3"].active():
			
			gv.g[x].partial_reset()
			
			gv.g[x].bought()
			
			gv.r["stone"].a(5)
			
			continue
		
		gv.g[x].partial_reset()
		
		get_node(gnLOREDs).cont[x].update_net(true)

func activate_refundable_upgrades(reset_type: int):
	
	for x in gv.up:
		if not gv.up[x].refundable:
			continue
		if not str(reset_type) == gv.up[x].type[1]:
			continue
		
		
		if not gv.up[x].normal:
			gv.stats.upgrades_owned[gv.up[x].type.split(" ", true, 1)[0]] += 1
		
		gv.up[x].refundable = false
		gv.up[x].have = true
		gv.up[x].active = true
		gv.up[x].times_purchased += 1
		
		gv.up[x].apply()
		
		get_node(gnupcon).cont[x].upgrade_effects(true, true)
		
		# quest stuff
		if taq.cur_quest != -1:
			for t in taq.quest.step:
				if x in t:
					taq.quest.step[t].f = Big.new()
		
		get_node(gnupcon).cont[x].r_update()

func reset_tasks(reset_type: int):
	
	if reset_type == 0:
		
		for q in gv.quest:
			q.reset()
		
		
		taq.max_tasks = 1
		taq.cur_quest = -1
		taq.cur_tasks = 0
		
		if not "tasks" in content_tasks.keys():
			return
		
		var list = []
		for x in taq.task:
			list.append(x)
		
		for x in list:
			content_tasks["tasks"].content[x].kill_yourself()
		
		content_tasks["tasks"].ready_task_count = 0
		content_tasks["tasks"].queue_free()
		content_tasks.erase("tasks")
		
		return
	
	
	
	var list = []
	for x in taq.task:
		if int(gv.g[taq.task[x].icon.key].type[1]) > reset_type:
			continue
		if "{Spike}" in taq.task[x].name:
			continue
		list.append(x)
	
	for x in list:
		content_tasks["tasks"].content[x].kill_yourself()
		var bla = content_tasks["tasks"].ready_task_count
		content_tasks["tasks"].ready_task_count = max(0, bla - 1)
	
	content_tasks["tasks"].hit_max_tasks()

func reset_limit_break(reset_type: int):
	
	if reset_type == 0:
		
		gv.reset_lb()
		
		activate_lb_effects()
		
		return
	
	gv.up["Limit Break"].sync()




# buttons
func _clear_content():
	for x in content:
		if not is_instance_valid(content[x]): continue
		content[x].queue_free()
	content.clear()




func b_tabkey(key):
	
	$global_tip._call("no")
	
	match key:
		
		KEY_ESCAPE:
			
			if get_node(gnupcon).visible:
				
				if get_node(gnupcon).get_node("v").visible:
					get_node(gnupcon).go_back()
				
				get_node(gnupcon).hide()
				
				return
			
			# open the menu
			if not $misc/menu.visible:
				$misc/menu.show()
				return
			
			# close the menu (should probably stay at the bottom. if must move above something, make this func return a bool. if return g.visible = true, then RETURN below the func)
			b_close_menu()
		
		KEY_1:
			switch_tabs("s1")
		
		KEY_2:
			switch_tabs("s2")
		
		KEY_3:
			switch_tabs("s3")
		
		KEY_4:
			switch_tabs("s4")
		
		KEY_Q:
			open_up_tab("s1n")
		
		KEY_W:
			open_up_tab("s1m")
		
		KEY_E:
			open_up_tab("s2n")
		
		KEY_R:
			open_up_tab("s2m")
		
		KEY_A:
			open_up_tab("s3n")

func switch_tabs(target: String):
	
	if not gv.stats.tabs_unlocked[target[1]]:
		return
	
	var int_tab = int(gv.menu.tab) - 1
	gv.menu.tab_vertical[int_tab] = get_node(gnLOREDs + "/sc").scroll_vertical
	
	gv.menu.tab = target[1] # "2"
	get_node("m/v/top/h/resources").switch_tabs(target[1])
	get_node(gnupcon).hide()
	
	for x in get_node(gnLOREDs + "/sc/v").get_children():
		if x.name in target:
			x.show()
		else:
			x.hide()
	
	var t = Timer.new()
	t.set_wait_time(0.005)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	
	int_tab = int(gv.menu.tab) - 1
	get_node(gnLOREDs + "/sc").scroll_vertical = gv.menu.tab_vertical[int_tab]

func open_up_tab(target: String):
	
	if not gv.stats.tabs_unlocked[target]:
		return
	
	get_node(gnupcon).col_time(target)
	
	b_close_menu()
	show_alert_guy(false)
	get_node("global_tip")._call("no")

func b_close_menu() -> void:
	$misc/menu.hide()
func b_move_map(x, y):

	$map.status = "no"
	$map.set_global_position(Vector2(x, y))


func unlock_tab(which: String, unlock := true):
	
	gv.stats.tabs_unlocked[which] = unlock
	
	if "s" in which:
		get_node(gnupcon).get_node("top/" + which).visible = unlock
	
	if which == "s1n":
		get_node("misc/tabs/v/upgrades").visible = unlock
	elif which.length() == 1:
		get_node("misc/tabs/v/s" + which).visible = gv.stats.tabs_unlocked[which]


func e_save(type := "normal", path := SAVE.MAIN):
	
	var save := _save.new()
	
	# menu and stats
	if true:
		
		save.game_version = ProjectSettings.get_setting("application/config/Version")
		
		for x in gv.stats.run.size():
			save.data["gv.stats.run[" + str(x) + "]"] = gv.stats.run[x]
			save.data["stats.last_run_dur[" + str(x) + "]"] = gv.stats.last_run_dur[x]
			save.data["stats.last_reset_clock[" + str(x) + "]"] = gv.stats.last_reset_clock[x]
		save.data["cur_clock"] = cur_clock
		save.data["times game loaded"] = times_game_loaded
		
		for x in gv.menu.option:
			save.data["option " + x] = gv.menu.option[x]
			if x == "on_save_menu_options" and not gv.menu.option[x]: break
		
		save.data["time_played"] = gv.stats.time_played
		save.data["tasks_completed"] = gv.stats.tasks_completed
		for x in gv.stats.r_gained:
			save.data["r_gained " + x] = gv.stats.r_gained[x].toScientific()
		
		save.data["most_resources_gained"] = gv.stats.most_resources_gained.toScientific()
		save.data["stats.highest_run"] = gv.stats.highest_run
		
		var ref := [Big.new(0), Big.new(0)]
		for x in gv.up:
			if gv.up[x].cost.size() == 0: continue
			if not gv.up[x].normal and gv.up[x].refundable:
				ref[0].a(gv.up[x].cost.values()[0].t)
		save.data["ref_0"] = ref[0].toScientific()
		save.data["ref_1"] = ref[1].toScientific()
		
		for x in gv.stats.last_reset_clock.size():
			save.data["save last reset clock " + String(x)] = gv.stats.last_reset_clock[x]
	
	
	# tasks
	if true:
		
		for q in gv.quest:
			save.data["task " + str(q.key) + " complete"] = q.complete
		
		if taq.cur_quest != -1:
			
			save.data["load quest"] = true
			
			save.data["on quest"] = taq.cur_quest
			var i = 0
			for r in taq.quest.req:
				save.data["quest req progress " + str(i)] = r.progress.toScientific()
		else:
			save.data["load quest"] = false
		
		var bla = 0
		for t in taq.task:
			
			var key = str(bla)
			
			save.data["task " + key + " name"] = t.name
			save.data["task " + key + " key"] = t.key
			save.data["task " + key + " icon"] = t.icon_key
			
			var i = 0
			for r in t.req:
				save.data["task " + key + " step key " + str(i)] = r.type
				save.data["task " + key + " b " + str(i)] = r.amount.toScientific()
				save.data["task " + key + " f " + str(i)] = r.progress.toScientific()
				i += 1
			save.data["task " + str(i) + " steps"] = i
			
			i = 0
			for r in t.reward:
				
				save.data["task " + key + " reward text " + str(i)] = r.text
				save.data["task " + key + " reward icon_key " + str(i)] = r.icon_key
				save.data["task " + key + " reward type " + str(i)] = str(r.type)
				if "amount" in r.other_keys:
					save.data["task " + key + " reward amount " + str(i)] = r.amount.toScientific()
				else:
					save.data["task " + key + " reward amount " + str(i)] = "0"
				if "other_key" in r.other_keys:
					save.data["task " + key + " reward other_key " + str(i)] = r.other_key
				else:
					save.data["task " + key + " reward other_key " + str(i)] = "NULL"
				
				i += 1
			save.data["task " + key + " rewards"] = str(i)
			
			bla += 1
		
		save.data["cur tasks"] = taq.cur_tasks
	
	
	# upgrades
	if true:
		
		if gv.up["Limit Break"].active():
			save.data["Limit Break d"] = gv.up["Limit Break"].effects[0].effect.a.toScientific()
			save.data["Limit Break xpf"] = gv.lb_xp.f.toScientific()
			save.data["Limit Break xpt"] = gv.lb_xp.t.toScientific()
		
		if gv.up["I DRINK YOUR MILKSHAKE"].active():
			save.data["[I DRINK YOUR MILKSHAKE] e0"] = gv.up["I DRINK YOUR MILKSHAKE"].effects[0].effect.a.toScientific()
		
		if gv.up["IT'S GROWIN ON ME"].active():
			save.data["[IT'S GROWIN ON ME] e0"] = gv.up["IT'S GROWIN ON ME"].effects[0].effect.a.toScientific()
			save.data["[IT'S GROWIN ON ME] e1"] = gv.up["IT'S GROWIN ON ME"].effects[1].effect.a.toScientific()
		
		if gv.up["IT'S SPREADIN ON ME"].active():
			save.data["[IT'S SPREADIN ON ME] e0"] = gv.up["IT'S SPREADIN ON ME"].effects[0].effect.a.toScientific()
			save.data["[IT'S SPREADIN ON ME] e1"] = gv.up["IT'S SPREADIN ON ME"].effects[1].effect.a.toScientific()
		
		for x in gv.up:
			save.data["[" + x + "] have"] = gv.up[x].have
			save.data["[" + x + "] refundable"] = gv.up[x].refundable
			save.data["[" + x + "] unlocked"] = gv.up[x].unlocked
			save.data["[" + x + "] times_purchased"] = gv.up[x].times_purchased
	
	# loreds
	if true:
		
		for x in gv.g:
			
			save.data["g" + x + " r"] = Big.new(gv.r[x]).roundDown().toScientific()
			save.data["g" + x + " active"] = gv.g[x].active
			save.data["g" + x + " unlocked"] = gv.g[x].unlocked
			save.data["g" + x + " key"] = gv.g[x].key_lored
			
			if not gv.g[x].active:
				continue
			
			save.data["g" + x + " level"] = gv.g[x].level
			save.data["g" + x + " fuel"] = gv.g[x].f.f.toScientific()
			
			save.data["g" + x + " halt"] = gv.g[x].halt
			save.data["g" + x + " hold"] = gv.g[x].hold
	
	# fin & misc
	if true:
		
		save.data["game version"] = save.game_version
		
		var save_file = File.new()
		
		match type:
			"normal":
				
				# create SAVE
				save_file.open(SAVE.MAIN, File.WRITE)
				save_file.store_line(Marshalls.variant_to_base64(save.data))
				save_file.close()
			
			"export":
				
				# create SAVE
				save_file.open(path, File.WRITE)
				save_file.store_line(Marshalls.variant_to_base64(save.data))
				save_file.close()
			
			"print to console":
				print("Your LORED save data is below! Click Expand, if necessary, for your save may be very large, and then save it in any text document!")
				print(Marshalls.variant_to_base64(save.data))
		
		w_aa()

func e_load(path := SAVE.MAIN) -> bool:
	
	var save_file = File.new()
	var save := _save.new()
	
	# file shit
	while true:
		
		if not save_file.file_exists(path):
			return false
		
		# load from base64
		save_file.open(path, File.READ)
		
		var save_lines := []
		
		save_lines.append(save_file.get_line())
		save_lines.append(save_file.get_line())
		
		if len(save_lines[0]) < 20:
			save.game_version = save_lines[0]
			save.data =  Marshalls.base64_to_variant(save_lines[1])
		else:
			save.data =  Marshalls.base64_to_variant(save_lines[0])
			save.game_version = save.data["game version"]
		
		
		save_file.close()
		
		break
	
	get_node(gn_patch).setup(save.game_version)
	
	if not "2" in save.game_version[0]:
		print("Save from 1.2c or earlier--what the heck, have you really not played since then? Welcome back, jeez!")
		return false
	
	var pre_beta_4 := false
	if "(" in save.game_version:
		var beta_version = save.game_version.split("(")[1].split(")")[0]
		if int(beta_version) <= 3:
			pre_beta_4 = true
	
	var keys = save.data.keys()
	
	load_stats(save.data, keys, pre_beta_4)
	load_upgrades(save.data, keys)
	load_loreds(save.data, keys, pre_beta_4)
	load_tasks(save.data, keys, save.game_version)

	# X.Y.Z
	# 2.1.0
	# 1.2c
	
	# shit that needs to be done before offline earnings
	if true:
		
		# limit break
		if true:
			
			activate_lb_effects()
	
	# offline earnings
	if true:
		
		var clock_dif = cur_clock - save.data["cur_clock"] - 10
		if clock_dif > 0:
			w_total_per_sec(clock_dif)
	
	# fin & misc
	if true:
		
		if gv.quest[gv.Quest.PRETTY_WET].complete:
			var butt = [gv.Quest.INTRO, gv.Quest.MORE_INTRO, gv.Quest.WELCOME_TO_LORED, gv.Quest.UPGRADES, gv.Quest.TASKS]
			for x in butt:
				gv.quest[x].complete = true
	
	return true

func load_stats(data: Dictionary, keys: Array, pre_beta_4: bool):
	
	for x in gv.stats.run.size():
		if "gv.stats.run[" + str(x) + "]" in keys:
			gv.stats.run[x] = data["gv.stats.run[" + str(x) + "]"]
		if "stats.last_run_dur[" + str(x) + "]" in keys:
			gv.stats.last_run_dur[x] = data["stats.last_run_dur[" + str(x) + "]"]
		if "stats.last_reset_clock[" + str(x) + "]" in keys:
			gv.stats.last_reset_clock[x] = data["stats.last_reset_clock[" + str(x) + "]"]
	times_game_loaded = data["times game loaded"] + 1
	
	for x in gv.menu.option:
		
		if not "option " + x in keys: continue
		if gv.PLATFORM == "browser" and x == "performance": continue
		
		gv.menu.option[x] = data["option " + x]
		if x == "on_save_menu_options" and not gv.menu.option[x]: break
	
	gv.stats.time_played = data["time_played"]
	gv.stats.tasks_completed = data["tasks_completed"]
	
	if "stats.highest_run" in keys:
		gv.stats.highest_run = data["stats.highest_run"]
	
	for x in gv.stats.last_reset_clock.size():
		if not ("save last reset clock " + str(x)) in keys: continue
		gv.stats.last_reset_clock[x] = data["save last reset clock " + str(x)]
	
	
	
	if pre_beta_4:
		
		for x in gv.stats.r_gained:
			if not "r_gained" + x in keys:
				continue
			gv.stats.r_gained[x] = Big.new(fval.f(data["r_gained " + x]))
		
		if "most_resources_gained" in keys:
			gv.stats.most_resources_gained = Big.new(fval.f(data["most_resources_gained"]))
		
		return
	
	
	
	for x in gv.stats.r_gained:
		if not "r_gained" + x in keys:
			continue
		gv.stats.r_gained[x] = Big.new(data["r_gained " + x])
	
	if "most_resources_gained" in keys:
		gv.stats.most_resources_gained = Big.new(data["most_resources_gained"])

func load_upgrades(data: Dictionary, keys: Array):
	
	if "Limit Break d" in keys:
		gv.up["Limit Break"].effects[0].effect.a = Big.new(data["Limit Break d"])
		gv.up["Limit Break"].sync_effects()
		gv.lb_xp.t = Big.new(data["Limit Break xpt"])
		gv.lb_xp.f = Big.new(data["Limit Break xpf"])
		emit_signal("limit_break_leveled_up", "color")
	
	if "[I DRINK YOUR MILKSHAKE] e0" in keys:
		gv.up["I DRINK YOUR MILKSHAKE"].effects[0].effect.a = Big.new(data["[I DRINK YOUR MILKSHAKE] e0"])
	
	if "[IT'S GROWIN ON ME] e0" in keys:
		gv.up["IT'S GROWIN ON ME"].effects[0].effect.a = Big.new(data["[IT'S GROWIN ON ME] e0"])
		gv.up["IT'S GROWIN ON ME"].effects[1].effect.a = Big.new(data["[IT'S GROWIN ON ME] e1"])
		
	if "[IT'S SPREADIN ON ME] e0" in keys:
		gv.up["IT'S SPREADIN ON ME"].effects[0].effect.a = Big.new(data["[IT'S SPREADIN ON ME] e0"])
		gv.up["IT'S SPREADIN ON ME"].effects[1].effect.a = Big.new(data["[IT'S SPREADIN ON ME] e1"])
	
	for x in gv.up:
		
		if not "[" + x + "] have" in keys: continue
		
		gv.up[x].have = data["[" + x + "] have"]
		if gv.up[x].have and gv.up[x].normal:
			gv.stats.up_list["unowned s" + gv.up[x].type[1] + "n"].erase(x)
		gv.up[x].refundable = data["[" + x + "] refundable"]
		if "[" + x + "] times_purchased" in keys:
			gv.up[x].times_purchased = data["[" + x + "] times_purchased"]
		if "[" + x + "] unlocked" in keys:
			gv.up[x].unlocked = data["[" + x + "] unlocked"]
		
		
		
		
		if not gv.up[x].refundable:
			if gv.up[x].active():
				gv.up[x].apply()
			continue
		
		gv.up[x].refundable = false
		
		gv.up[x].sync_cost()
		
		for c in gv.up[x].cost:
			gv.r[c].a(gv.up[x].cost[c].t)
	
	for x in gv.up:
		gv.up[x].sync()
		if not gv.up[x].have: continue
		gv.stats.upgrades_owned[gv.up[x].type.split(" ", true, 1)[0]] += 1

func load_loreds(data: Dictionary, keys: Array, pre_beta_4: bool):
	
	for x in gv.g:
		if gv.g[x].stage == "3":
			continue
		if not "g" + x + " active" in keys:
			continue
		gv.g[x].active = data["g" + x + " active"]
		gv.r[x].a(Big.new(data["g" + x + " r"]))
		if "g" + x + " unlocked" in keys:
			gv.g[x].unlocked = data["g" + x + " unlocked"]
		if "g" + x + " key" in keys:
			gv.g[x].key_lored = data["g" + x + " key"]
		
		if not gv.g[x].active:
			continue
		
		gv.g[x].level = data["g" + x + " level"]
		
		if x != "stone":
			gv.g[x].increase_cost()
		
		for v in gv.g[x].level - 1:
			gv.g[x].d.m.m(2)
			gv.g[x].fc.m.m(2)
			gv.g[x].f.m.m(2)
			gv.g[x].increase_cost()
		
		if gv.menu.option["on_save_halt"] and "g" + x + " halt" in keys: gv.g[x].halt = data["g" + x + " halt"]
		if gv.menu.option["on_save_hold"] and "g" + x + " hold" in keys: gv.g[x].hold = data["g" + x + " hold"]
		
		get_node(gnLOREDs).cont[x].start_all()
		
		if pre_beta_4:
			
			gv.g[x].f.f = Big.new(fval.f(data["g" + x + " fuel"]))
		
		else:
			
			gv.g[x].f.f = Big.new(data["g" + x + " fuel"])
		
		gv.g[x].sync()

func load_tasks(data: Dictionary, keys: Array, game_version: String):
	
	for q in gv.quest:
		if "task " + str(q.key) + " complete" in keys:
			q.complete = data["task " + str(q.key) + " complete"]
	
	if "load quest" in keys:
		if data["load quest"]:
			if data["on quest"] in gv.Quest:
				taq.new_quest(gv.quest[data["on quest"]])
				for x in taq.quest.step:
					if not "quest step " + x + " f" in keys:
						continue
					
					taq.quest.step[x].f = Big.new(data["quest step " + x + " f"])
	
	if int(game_version[2]) < 4:
		return
	
	if "cur tasks" in keys:
		for i in data["cur tasks"]:
			
			if taq.cur_tasks >= taq.max_tasks:
				break
			if not "task " + str(i) + " name" in keys:
				continue
			
			var pack := {}
			var key = str(i)
			
			pack["name"] = data["task " + str(i) + " name"]
			pack["icon_key"] = data["task " + str(i) + " icon"]
			pack["reqs"] = []
			pack["reward"] = []
			
			for ii in data["task " + str(i) + " rewards"]:
				pack["reward"].append(
					Task.Reward.new(
						data["task " + key + " reward type " + str(ii)],
						data["task " + key + " reward text " + str(ii)],
						data["task " + key + " reward icon_key " + str(ii)],
						{
							"amount": data["task " + key + " reward amount " + str(i)],
							"other_key": data["task " + key + " reward other_key " + str(i)]
						}
					)
				)
			
			taq.task.append(Task.new(data["task " + key + " key"], pack))# name, desc, rr, r, steps, icon, gv.COLORS[data["task " + str(i) + " icon"]])


func _on_Button_pressed() -> void:
	
	#gv.r["flayed corpse"].a(3)
	
	#var Cawk = Big.new(100)
	
	#print(Big.new(Cawk).power(1.5).toString())
	
	
	pass



func can():
	return true

func my_func():
	print("Hello")
	
	if yield():
		return "test"
	return "cock"
