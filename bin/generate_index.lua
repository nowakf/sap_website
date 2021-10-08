#!/usr/bin/luajit

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
	local header, article_s = s:match('%-%-%-+\n(.-)%-%-%-+()')
	local elem = {
		filename = arg
	}
	for line in header:gmatch('.-\n') do
		key, value = line:match('%s*(%S+)%s*:%s*(.-)\n')
		elem[key] = value
	end
	local fold_end = s:find('<!--more-->', article_start, true)
	elem.above_fold = s:sub(article_s, fold_end-1)
	front_matter[i] = elem
end

--v. simplistic YY MM DD
function parse_date(date)
	local cnt = 0;
	local val = 0;
	local date_scales = {1, 12, 31}
	for part in date:gmatch('(%d+)%-') do
		val = val + tonumber(part) * date_scales[cnt+1]
	end
	return val
end

table.sort(front_matter, function(a, b) return parse_date(a.date) > parse_date(b.date) end)

for _, elem in ipairs(front_matter) do
	print(string.format([[
#### [%s](%s)
%s
%s
	]], elem['title'], elem['filename'], elem['date'], elem['above_fold']))
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
