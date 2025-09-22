#!/usr/bin/luajit

function linkify(filename)
	return filename:match('^.+/(.+)$'):gsub('%.md', '.html')
end

local front_matter = {}

--some pretty rough yaml parsing here. It'll prolly shit at some point
--it shat
for i, a in ipairs(arg) do
	local f = assert(io.open(a))
	local s = assert(f:read('*a'))
	local header, article_s = s:match('%-%-%-+\n(.-)%-%-%-+()') 
	if not header or not article_s then
		error('article has no header?')
	end
	local elem = {
		filename = linkify(a)
	}
	for line in header:gmatch('.-\n') do
		key, value = line:match('%s*(%S+)%s*:%s*(.-)\n')
		elem[key] = value
	end
	local fold_end = s:find('<!--more-->', article_start, true) or article_s + 1
	elem['above_fold'] = s:sub(article_s, fold_end-1)
	front_matter[i] = elem
end

--v. simplistic YY MM DD
function parse_date(date)
	local cnt = 1;
	local val = 0;
	local date_scales = {1, 12, 31}
	for part in date:gmatch('(%d+)%-') do
		val = val + tonumber(part) / date_scales[cnt]
		cnt = cnt+1
	end
	return val
end

table.sort(front_matter, function(a, b) return parse_date(a.date) > parse_date(b.date) end)

local post_template = [[
<div class="post-title-box"> 
<div class="post-title"> <a href="%s">%s</a></div>
<p class="date">%s</p> </div>
%s
[more...](%s)
]]

print([[
---
title: nowakf
---
]])

for _, elem in ipairs(front_matter) do
	print(string.format(post_template, elem['filename'],
						elem['title'],
						elem['date']:match('%d+%p%d+%p%d+'):gsub('-', '.'),
						elem['above_fold'],
						elem['filename']))
end

