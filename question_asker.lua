-- simple function that reads the file provided as a path
-- and returns the text within
local read_deck = function(path_to_file)
	local f = io.open(path_to_file, "r")
	local res = f:read("*a")
	io.close()
	return res
end

-- returns a copy of the table named "tab" where there are no empty elements
local get_normalized_table = function(tab)
	local res = {}
	for _,elem in pairs(tab) do
		if #elem > 0 then
			res[#res +1] = elem
		end
	end
	return res
end

-- given a string and a char splits the string into a table from the char
-- then normalizes the table (white splace between the meaningful lines might cause
-- problems)
local split = function(str, char)
	local res = {}
	local temp = ""

	for i = 1, #str do
		if string.sub(str, i,i) == char then
			res[#res + 1] = temp
			temp = ""
		else
			temp = temp .. string.sub(str,i,i)
		end
	end

	res[#res +1] = temp

	return get_normalized_table(res)

end

-- returns a table such that the element named "front" return the front of the card
-- and element named "back" return the back of the card
local create_card = function(front_of_card,back_of_card, is_learned)
	local res = {front = front_of_card, back = back_of_card, learned = is_learned}
	return res
end

-- given a path to a file uses the previously mentioned functions
-- to create a table full of "cards"
local create_deck_from_file = function(path_to_file)
	local res = {}
	local text = read_deck(path_to_file)
	local t = split(text, "\n")
	for _,elem in pairs(t) do
		local split_up_line = split(elem, ",")
		local front = split_up_line[1]
		local back = split_up_line[2]
		local learned = split_up_line[3]
		res[#res + 1] = create_card(back,front, learned)
	end
	return res
end

-- takes in a string and reformats it such that it will fit inside a "card" display
local convert_str_to_displayable = function(str, max_length)
	local res = ""
	local t = split(str, " ")
	local char_per_line = 0
	for _,elem in pairs(t) do
		if  char_per_line + #elem >= max_length then
			res = res .. "\n" .. elem
			char_per_line = 0
		else
			res = res .. " " .. elem 
			char_per_line = char_per_line + #elem
		end
	end
	return res
end


-- just give the function a string that will be displayed, the width of the card
-- and the margin between the left edge of the card and the begining of the stirng
local display_string_in_card = function(str, width, margin)

	local in_square = convert_str_to_displayable(str, width-margin*2)
	local t = split(in_square, "\n")
	local max_length = 0
	for _,elem in pairs(t) do
		if #elem > max_length then
			max_length = #elem
		end
	end

	local up_down = max_length + margin*2 -2
	io.write("/")
	for i = 1, up_down do
		io.write("-")
	end
	io.write("\\\n")

	for _,elem in pairs(t) do
		local to_be_printed = "|"
		for i = 1, margin-1 do
			to_be_printed = to_be_printed .. " "
		end


			to_be_printed = to_be_printed .. elem

			for i = 1, margin + (max_length - #elem) -1 do
				to_be_printed = to_be_printed .. " "
			end
			print(to_be_printed .. "|")
	end

	io.write("\\")
	for i = 1, up_down do
		io.write("-")
	end
	io.write("/\n")

end
--
-- given a deck, converts it to a multi line string with the appropriate formatting
-- and writes the string to the given file
local update_deck_if_learned = function(path_to_file, updated_deck)
	local deck_as_string = ""

	for _,elem in pairs(updated_deck) do
		local card_as_string = elem["back"] .. "," .. elem["front"]  .. "," .. elem["learned"] .. "\n"
		deck_as_string = deck_as_string .. card_as_string
	end

	local file = io.open(path_to_file, "w")
	file:write(deck_as_string)
	io.close()


end

-- shuffles the table that contins "cards"
local shuffle_deck = function(deck)
	for i = 1, #deck do
		local index = math.random() % #deck + 1
		local temp = deck[i]
		deck[i] = deck[index]
		deck[index] = temp
	end
end

-- given a deck loops over the deck and does the following
-- randomly picks either "front" or "back" of the card to be the question that will be asked and sets the other to be the answer
-- prints the the question to the screen
-- gets the user input and turns it lower case (we are not testing for punctuation)
-- if the ans is equal to the user answer increments the score
-- returns score
local test_user_on_deck = function(deck, width,margin, ask_known)

	local score = 0

	if ask_known then
		for _,card in pairs(deck) do

			local question = ""
			local answer = ""

			if math.random(100) % 2 == 0 then
				question = card["back"]
				answer = card["front"]
			else
				question = card["front"]
				answer = card["back"]
			end

			display_string_in_card(question, width,margin)
			local user_ans = string.lower(io.read())

			if user_ans == answer then
				score = score + 1
			end

		end
	else
		for _,card in pairs(deck) do

			if card["learned"] == "n" then
				local question = ""
				local answer = ""

				if math.random(100) % 2 == 0 then
					question = card["back"]
					answer = card["front"]
				else
					question = card["front"]
					answer = card["back"]
				end

				display_string_in_card(question, width,margin)
				local user_ans = string.lower(io.read())

				if user_ans == answer then
					score = score + 1
				end

			end
		end
	end

	return score

end

-- main function that get ran when needs be
test = function(path_to_file, card_width, card_margin, ask_knowns)
	local txt = read_deck(path_to_file)

	local t = split(txt, "\n")
	local num_of_cards = #t

	local deck = create_deck_from_file(path_to_file)

	local res = test_user_on_deck(deck,card_width,card_margin, ask_knowns)

	if not ask_knowns then
		update_deck_if_learned(path_to_file, deck)
	end

	return {score = res, success = res/num_of_cards}

end

return test
