local ffi = require 'ffi'

local function slurp(path)
	local f = assert(io.open(path, 'r'))
	local contents = f:read('*all')
	f:close()
	return contents
end

ffi.cdef(slurp('./yaml_stripped.h'))

local lyaml = ffi.load('yaml')

local parser

local mt = {
	__index = {
		set_input_string = function(self, str) 
			lyaml.yaml_parser_set_input_string(self, str, #str)
		end,
		parse = function(self)
			local event = ffi.new('yaml_event_t')
			local ret = lyaml.yaml_parser_parse(self, event)
			if ret then 
				print(event)
			else
				print(ret, "errr")
			end
		end,
	},
	__gc = function(self)
		lyaml.yaml_parser_delete(self)
	end,
	
}

parser = ffi.metatype('yaml_parser_t', mt)

function Parser()
	local p = ffi.new('yaml_parser_t')
	lyaml.yaml_parser_initialize(p)
	return p
end

return Parser
