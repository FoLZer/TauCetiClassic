/obj/item/organ/external/chest/robot/bionic
	name = "ipc chest"

/obj/item/organ/external/chest/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/head/robot/bionic
	name = "bionic head"
	vital = FALSE

/obj/item/organ/external/head/robot/bionic/is_compatible(mob/living/carbon/human/H)
	if(H.species.name == BIONIC)
		return TRUE

	return FALSE

/obj/item/organ/external/head/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/groin/robot/bionic
	name = "bionic groin"

/obj/item/organ/external/groin/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/l_arm/robot/bionic
	name = "left bionic arm"

/obj/item/organ/external/l_arm/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/r_arm/robot/bionic
	name = "right bionic arm"

/obj/item/organ/external/r_arm/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/r_leg/robot/bionic
	name = "right bionic leg"

/obj/item/organ/external/r_leg/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color

/obj/item/organ/external/l_leg/robot/bionic
	name = "left bionic leg"

/obj/item/organ/external/l_leg/robot/bionic/update_sprite()
	icon = species.icobase
	icon_state = "[body_zone]"
	color = original_color
