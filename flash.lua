local test = require("question_asker")

local print_help = function()
	print("-p : the following parameter is the path")
	print("-k : the known cards will be asked as well (the state of the cards will not change)")
	print("-a : adding a new card to the given deck with -p")
end

local main = function(args)
	local ask_known = false
	local will_be_adding = false
	local path = ""
	local exit = false

	local score = 0

	local index = 1
	while index <= #args do
		if args[index] == "-p" then
			index = index+1
			path = args[index]
		elseif args[index] == "-k" then
			ask_known = true
		elseif args[index] == "-a" then
			print("back of card")
			local b = io.read()
			print("front of card")
			local f = io.read()
			local file = io.open(path,"a")
			file:write(b .. "," .. f .. ",n")
			io.close()
			exit = true
		elseif #args == 0 then
			exit = true
		else
			print_help()
			exit = true
		end
		index = index+1
	end


	if not exit then
		score = test(path, 20,5,ask_known)["score"]
		print("You answered " .. score .. " cards correctly")
	end


end

main(arg)
