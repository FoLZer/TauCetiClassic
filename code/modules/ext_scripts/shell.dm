//Runs the command in the system's shell, returns a list of (error code, stdout, stderr)

#define SHELLEO_NAME "data/shelleo."
#define SHELLEO_ERR ".err"
#define SHELLEO_OUT ".out"
/world/proc/shelleo(command)
	var/stdout = ""
	//shell("start /wait cmd /c \"[command]\" > .shell")
	var/exit = 0
	exit << shell("[command]")
	if(!exit)
		stdout = "{\"success\": 1}"
	else
		stdout = "{\"success\": 0}"
	return stdout
#undef SHELLEO_NAME
#undef SHELLEO_ERR
#undef SHELLEO_OUT
