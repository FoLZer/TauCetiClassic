/obj/effect/landmark/nostromo_xeno
	name = "Nostromo-Alien-Spawn"

/obj/effect/landmark/nostromo_syndie
	name = "Nostromo-Syndicate-Spawn"

/datum/game_mode/nostromo
	name = "nostromo"
	config_tag = "nostromo"
	role_type = ROLE_OPERATIVE
	required_players = 10
	required_players_secret = 10
	required_enemies = 2
	recommended_enemies = 4
	var/num_traders = 0
	var/list/xenomorphs = list()
	votable = 0


/datum/game_mode/nostromo/announce()
	to_chat(world, "<B>Текущий режим : __!</B>")
	to_chat(world, "Внимание! На станцию вот-вот прибудут межгалактические торговцы. Кто знает, что они за собой понесут?")

/datum/game_mode/nostromo/can_start()
	if (!..())
		return FALSE
	// Looking for map to nuclear spawn points
	var/spwn_synd = FALSE
	var/spwn_xeno = FALSE
	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Nostromo-Syndicate-Spawn")
			spwn_synd = TRUE
		else if (A.name == "Nostromo-Alien-Spawn")
			spwn_xeno = TRUE
		if (spwn_synd && spwn_xeno)
			return TRUE
	return FALSE

/datum/game_mode/nostromo/assign_outsider_antag_roles()
	if(!..())
		return FALSE
	var/antag_number = 0

	//Antag number should scale to active crew.
	var/n_players = num_players()
	antag_number = CLAMP((n_players/5), required_enemies, recommended_enemies)

	if(antag_candidates.len < antag_number)
		antag_number = antag_candidates.len

	while(antag_number > 1)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		antag_number--
		num_traders++

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Merchant"//So they actually have a special role/N
	//	log_game("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative")
	//	message_admins("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative",0,1)
		forge_merchant_objectives(synd_mind)

	var/datum/mind/new_xeno = pick(antag_candidates)
	new_xeno.assigned_role = "MODE"
	new_xeno.special_role = "Xenomorph"
	forge_xeno_onjectives(new_xeno)
	antag_number--
	xenomorphs.Add(new_xeno)

	return TRUE

/datum/game_mode/proc/forge_merhant_objectives(datum/mind/merhant)
	var/datum/objective/harm/harm = new
	harm.owner = merhant
	merhant.objectives += harm

	var/datum/objective/steal/steal = new
	steal.owner = merhant
	merhant.objectives += steal

/datum/game_mode/proc/forge_xeno_objectives(datum/mind/xeno)
	var/datum/objective/nostromo/xeno/kill/kill = new
	kill.owner = xeno
	xeno.objectives += kill

	var/datum/objective/nostromo/xeno/infest/infest = new
	infest.owner = xeno
	xeno.objectives += infest

	var/datum/objective/nostromo/xeno/breakout/breakout = new
	breakout.owner = xeno
	xeno.objectives += breakout

	var/datum/objective/nostromo/xeno/leave/leave = new
	leave.owner = xeno
	xeno.objectives += leave

/datum/game_mode/nostromo/pre_setup()
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nostromo/post_setup()

	var/list/turf/synd_spawn = list()
	var/turf/xeno_spawn

	for(var/obj/effect/landmark/A in landmarks_list) //Add commander spawn places first, really should only be one though.
		if(A.name == "Nostromo-Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			continue

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Nostromo-Alien-Spawn")
			xeno_spawn = get_turf(A)
			qdel(A)
			break

	var/spawnpos = 1

	for(var/datum/mind/synd_mind in syndicates)
		log_debug("Starting cycle - Ckey:[synd_mind.key] - [synd_mind]")
		synd_mind.current.faction = "merchants"
		synd_mind.current.real_name = "Merchant" // placeholder while we get their actual name
		log_debug("[synd_mind] - merchant")
		greet_merchant(synd_mind)
		equip_syndicate(synd_mind.current)
		if(spawnpos > synd_spawn.len)
			spawnpos = 1
		log_debug("[synd_mind] telepoting to [synd_spawn[spawnpos]]")
		synd_mind.current.loc = synd_spawn[spawnpos]

		spawnpos++

	for(var/datum/mind/xeno in xenomorphs)
		log_debug("Starting cycle - Ckey:[xeno.key] - [xeno]")
		synd_mind.current.faction = "xenomorphs"
		synd_mind.current.real_name = "Xenomorph"
		log_debug("[xeno] - xenomorph")
		greet_xeno(xeno)

		var/mob/living/carbon/xenomorph/humanoid/hunter/H = new /mob/living/carbon/xenomorph/facehugger(start_point)
		var/mob/original = xeno.current

		xeno.transfer_to(H)

		greet_xeno(xeno)
		qdel(original)
	return ..()

/datum/game_mode/proc/greet_merchant(datum/mind/merchant)
	to_chat(merchant.current, "<span class = 'info'>You are a <font color='red'>Merchant</font>!</span>")
	//merchant.current.playsound_local(null, 'sound/antag/ops.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(merchant.current, "<font color=blue>Поздравляем! По вашим заявкам, компания Weyland-Yutani согласилась взять вас на стажировку межгалактического торговца!</font>")
	to_chat(merchant.current, "<font color=blue>На вашей станции имеется всё возможное, что могло бы стать отличной прибылью для вас. Начиная от материалов, заканчивая нелегальными устройствами. \nВаша цель - продать как можно больше предметов, выполнить указания компании и получить контроль над станцией.</font>")
	to_chat(merchant.current, "<font color=blue>По окончанию смены улететь на трансфере/спасательном шаттле. (Примечание: Вам следует отыгрывать глупойкий РП. Прежде всего, \nвы - космический пират, который притворяется торговцем. В случае непонятных ситуаций или ступоров, обращайтесь в adminhelp.</font>")
	to_chat(merchant.current, "<font color=blue><b>Не бойтесь пользоваться помощью педалей. Удачной игры!)</b></font>")

/datum/game_mode/proc/greet_xeno(datum/mind/xeno)
	to_chat(xeno.current, "<span class = 'info'>You are a <font color='purple'>Xeno</font>!</span>")
	to_chat(xeno.current, "<font color=blue><i>вы слышите шёпот....<i> Это я... королева... Мы находимся на 'станционной военной лаборатории'.. Как ты уже знаешь...</font>")
	to_chat(xeno.current, "<font color=blue>Весь наш род заключили в клетки... в том числе и меня... Люди вырастили тебя там.. и назвали тебя - Шестая... Если ты сумеешь</font>"")
	to_chat(xeno.current, "<font color=blue>выбраться... я приказываю тебе уничтожить всё живое... В 'пещерах' я запрятала одно из яиц... береги его... <i>вы услышали визг,</i></font>"")
	to_chat(xeno.current, "<font color=blue><i>а затем шёпот прекратился...</i> (Примечание: Вы можете пойти как по стопам 'убийцы', так и продолжить род </font>"")
	to_chat(xeno.current, "<font color=blue>(в тех отделах 1 яйцо). 'Вторая сестра' может эволюционировать в королеву (это не навредит канону, так как по сюжету </font>"")
	to_chat(xeno.current, "<font color=blue>ивента королеву убили). Если у вас возникнут вопросы, обращайтесь в adminhelp.)</font>"")

///datum/game_mode/nostromo/check_win()
//	if (nukes_left == 0)
//		return 1
//	if ()
//	return ..()

/datum/game_mode/nostromo/proc/check_xeno_victory()
	var/success = 0
	for(var/datum/mind/xenos in xenomorphs)
		if(xenos.current && xenos.current.stat != DEAD)
			success++
	return success

/datum/game_mode/nostromo/declare_completion()
	if(config.objectives_disabled)
		return
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		var/disk_area = get_area(D)
		if(!is_type_in_typecache(disk_area, centcom_areas_typecache))
			disk_rescued = 0
			break
	var/crew_evacuated = (SSshuttle.location==2)
	if(check_xeno_victory())
		mode_result = 'win - xeno is dead'
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: green; font-weight: bold;'>Crew Major Victory!</span>"
	else
		mode_result = 'loose - crew is dead'
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: green; font-weight: bold;'>Xeno Major Victory!</span>"

	..()
	return 1
