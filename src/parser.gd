extends Node
class_name Parser

static func parse_ini(file_path: String) -> ConfigFile:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var config := ConfigFile.new()
	var section: String
	print("Parsing file: " + file_path)

	while file.is_open():
		if file.eof_reached():
			file.close()
			break;
		var line := file.get_line()

		if line.begins_with("["):
			# Parse the section header
			section = line.substr(1, line.length() - 2)
		elif line.begins_with(";") or line.begins_with(" ") or line.is_empty():
			# Skip comments
			continue
		else:
			if section.is_empty():
				print("Error: Section header not found")
				break;
			# Parse the key-value pair
			var key_value := line.split("=", true)
			var key := key_value[0].strip_edges()
			var value := key_value[1].strip_edges()

			config.set_value(section, key, value)

	print("Done parsing file")
	return config

static func parse_chart(file_path: String) -> ConfigFile:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var config := ConfigFile.new()
	var section: String

	print("Parsing file: " + file_path)

	while file.is_open():
		if file.eof_reached():
			file.close()
			break;
		var line := file.get_line()

		if (line.begins_with("{") or line.begins_with("}") or 
			line.begins_with(";") or line.is_empty()):
			# Skip comments and other stuff
			continue

		if line.begins_with("["):
			# Parse the section header
			section = line.substr(1, line.length() - 2)
			print("Section: " + section)
		else:
			if section.is_empty():
				print("Error: Section header not found")
				break;
			# Parse the key-value pair
			var key_value := line.split("=", true)
			var key := key_value[0].strip_edges()
			var value: Variant = key_value[1].strip_edges()

			if value.begins_with("\""):
				value = value.substr(1, value.length() - 2)
			elif value.is_valid_int():
				value = value.to_int()
			elif value.split(" ").size() == 1:
				pass
			else:
				var arr := []
				var split = value.split(" ")
				if split[0] == "E":
					continue
				elif split[0] == "TS" or split[0] == "B":
					arr.append(split[0])
					arr.append(split[1])
				else:
					arr.append(split[0])
					arr.append(split[1])
					arr.append(split[2])
				value = arr
				print("Value: ", value)

			config.set_value(section, key, value)

	print("Done parsing file")
	return config

