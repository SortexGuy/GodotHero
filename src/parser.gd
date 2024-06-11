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

static func parse_chart(file_path: String) -> Dictionary:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var dict := {}
	var inner_dict := {}
	var section: String

	# For storing note info in which the spawn time might be duplicated
	var data_arr: = []
	var data_section: bool = false

	print("Parsing file: " + file_path)
	while file.is_open():
		if file.eof_reached():
			file.close()
			break;
		var line := file.get_line()
		
		if (line.begins_with("{") or 
			line.begins_with(";") or line.is_empty()):
			print("Skipping line in: ", section)
			# Skip comments and other stuff
			continue
		elif line.begins_with("}"):
			# Close and save data or ignore if is just info
			if not data_section:
				dict[section] = inner_dict.duplicate(true)
				inner_dict.clear()
			else:
				dict[section] = data_arr.duplicate(true)
				data_arr.clear()
			print("Closing ", section)
			continue
		
		if line.begins_with("["):
			# Parse the section header
			section = line.substr(1, line.length() - 2)
		else:
			if section.is_empty():
				print("Error: Section header not found")
				break;

			# Parse the key-value pair
			var key_value := line.split("=", true)
			var key = key_value[0].strip_edges()
			var value: Variant = key_value[1].strip_edges()

			if key.is_valid_int(): # Parse data (notes and events)
				data_section = true
				var split: PackedStringArray = value.split(" ")
				value = []
				
				if split[0] == "E": # Skip event tag
					continue

				if split[0] == "TS" or split[0] == "B": # Skip sync tags
					continue
				
				# Get two values from the key-value pair (tag, type)
				value.append(split[0])
				value.append(split[1].to_int())
				if split[0] == "N": # If note get sustain as third value
					# value.append(split[0])
					# value.append(split[1].to_int())
					value.append(split[2].to_int())
				
				# Save data-point as [time, [tag, type{, sustain}]]
				data_arr.append([key.to_int(), value])
			else:
				if value.begins_with("\""): # Parse raw string
					value = value.substr(1, value.length() - 2)
				elif value.is_valid_int(): # Parse raw int
					value = value.to_int()
				elif value.split(" ").size() == 1: # Parse maybe enum (?)
					pass
				inner_dict[key] = value
		
		# End of loop
	
	print("Done parsing file")
	return dict
