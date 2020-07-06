/obj/effect/landmark/nostromo_xeno
	name = "Nostromo-Alien-Spawn"

/obj/effect/landmark/nostromo_syndie
	name = "Nostromo-Syndicate-Spawn"

/datum/game_mode/nostromo
	name = "nuclear emergency"
	config_tag = "nuclear"
	role_type = ROLE_OPERATIVE
	required_players = 15
	required_players_secret = 25
	required_enemies = 2
	recommended_enemies = 6

	votable = 0

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 20

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level


/datum/game_mode/nostromo/announce()
	to_chat(world, "<B>The current game mode is - Nostromo!</B>")
	//to_chat(world, "<B>Gorlex Maradeurs are approaching [station_name()]!</B>")
	//to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")

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
	var/agent_number = 0

	//Antag number should scale to active crew.
	var/n_players = num_players()
	agent_number = CLAMP((n_players/5), required_enemies, recommended_enemies)

	if(antag_candidates.len < agent_number)
		agent_number = antag_candidates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
	//	log_game("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative")
	//	message_admins("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative",0,1)
	return TRUE

/datum/game_mode/nostromo/pre_setup()
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nostromo/post_setup()

	var/list/turf/synd_spawn = list()
	var/turf/synd_comm_spawn

	for(var/obj/effect/landmark/A in landmarks_list) //Add commander spawn places first, really should only be one though.
		if(A.name == "Syndicate-Commander")
			synd_comm_spawn = get_turf(A)
			qdel(A)
			continue

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/spawnpos = 1
//	var/max_age = 0
/*	for(var/datum/mind/synd_mind in syndicates)
		if(isnum(synd_mind.current.client.player_age))
			if(max_age<synd_mind.current.client.player_age)
				max_age = synd_mind.current.client.player_age */

	for(var/datum/mind/synd_mind in syndicates)
		log_debug("Starting cycle - Ckey:[synd_mind.key] - [synd_mind]")
		synd_mind.current.faction = "syndicate"
		synd_mind.current.real_name = "Gorlex Maradeurs Operative" // placeholder while we get their actual name
		log_debug("Leader status [leader_selected]")
		if(!leader_selected)
			log_debug("Leader - [synd_mind]")
			synd_mind.current.loc = synd_comm_spawn
			equip_syndicate(synd_mind.current, 1)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
			greet_syndicate(synd_mind, 0, 1)
		else
			log_debug("[synd_mind] - not a leader")
			greet_syndicate(synd_mind)
			equip_syndicate(synd_mind.current)
			if(spawnpos > synd_spawn.len)
				spawnpos = 1
			log_debug("[synd_mind] telepoting to [synd_spawn[spawnpos]]")
			synd_mind.current.loc = synd_spawn[spawnpos]

		spawn(0)
			NukeNameAssign(synd_mind)

		if(!config.objectives_disabled)
			forge_syndicate_objectives(synd_mind)

		spawnpos++
		update_synd_icons_added(synd_mind)

	update_all_synd_icons()

	if(uplinklocker)
		var/obj/structure/closet/C = new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
		spawn(10) //gives time for the contents to spawn properly
			for(var/obj/item/thing in C)
				if(thing.hidden_uplink)
					nuclear_uplink = thing
					break
	if(nuke_spawn)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()

/datum/game_mode/nostromo/check_win()
	if (nukes_left == 0)
		return 1
	return ..()

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
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if      (!disk_rescued &&  station_was_nuked &&          !syndies_didnt_escape)
		mode_result = "win - syndicate nuke"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Major Victory!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives have destroyed [station_name()]!</b>"
		score["roleswon"]++

	else if (!disk_rescued &&  station_was_nuked &&           syndies_didnt_escape)
		mode_result = "halfwin - syndicate nuke - did not evacuate in time"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Total Annihilation</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		mode_result = "halfwin - blew wrong station"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Minor Victory</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives secured the authentication disk but blew up something that wasn't [station_name()].</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		mode_result = "halfwin - blew wrong station - did not evacuate in time"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Gorlex Maradeurs span earned Darwin Award!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives blew up something that wasn't [station_name()] and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		mode_result = "loss - evacuation - disk secured - syndi team dead"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory!</span>"
		completion_text += "<br><b>The Research Staff has saved the disc and killed the Gorlex Maradeurs Operatives</b>"

	else if ( disk_rescued                                        )
		mode_result = "loss - evacuation - disk secured"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory</span>"
		completion_text += "<br><b>The Research Staff has saved the disc and stopped the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		mode_result = "loss - evacuation - disk not secured"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		completion_text += "<br><b>The Research Staff failed to secure the authentication disk but did manage to kill most of the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		mode_result = "halfwin - detonation averted"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</b> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		mode_result = "halfwin - interrupted"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Neutral Victory</span>"
		completion_text += "<br><b>Round was mysteriously interrupted!</b>"

	..()
	return 1
