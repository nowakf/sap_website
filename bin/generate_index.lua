#!/usr/bin/luajit
require 'lyaml'

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function linkify(filename)
	return filename:match('^.+/(.+)$'):gsub('.md', '.html')
end

local front_matter = {}

for i, a in ipairs(arg) do
	local f = assert(io.open(a))
	local s = assert(f:read('*a'))
	local header = s:match('%-%-%-+.*%-%-%-+')
	front_matter[i] = lyaml.load(header)
end

for _, a in ipairs(arg) do
	local f = assert(io.open(a))
	local s = assert(f:read('*a'))
	local title, article_start = s:match('title:%s*(.-)\n.-%-%-+()')
	local fold_end = s:find('<!--more-->', article_start, true)
	print(string.format('#### [%s](%s)\n', title, linkify(a)))
	if fold_end and fold_end > article_start then
		print(s:sub(article_start, fold_end-1) .. '\n')
	end
end
