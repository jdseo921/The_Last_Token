extends RefCounted

## Keeps long single-line captions readable by choosing the word break closest
## to the visual midpoint. Authored line breaks are left intact.


static func split_balanced(text: String, minimum_characters := 58) -> String:
	var clean_text := text.strip_edges()
	if clean_text.length() < minimum_characters or clean_text.contains("\n"):
		return clean_text
	var words := clean_text.split(" ", false)
	if words.size() < 4:
		return clean_text
	var best_split := 1
	var smallest_difference := clean_text.length()
	for split_index in range(1, words.size()):
		var left_length := " ".join(words.slice(0, split_index)).length()
		var right_length := " ".join(words.slice(split_index)).length()
		var difference := absi(left_length - right_length)
		if difference < smallest_difference:
			smallest_difference = difference
			best_split = split_index
	var left := " ".join(words.slice(0, best_split))
	var right := " ".join(words.slice(best_split))
	return "%s\n%s" % [left, right]
