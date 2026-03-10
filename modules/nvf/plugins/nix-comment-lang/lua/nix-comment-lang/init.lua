local M = {}

local ns = vim.api.nvim_create_namespace("nix_string_ghost")

-- Check if buffer is a nix file
local function is_nix(buf)
	return vim.api.nvim_buf_get_option(buf, "filetype") == "nix"
end

local function cursor_within(node)
	local start_row, _, end_row, _ = node:range()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

	if cursor_row >= start_row and cursor_row <= end_row then
		return true
	end

	return false
end

local function conceal_node(buf, ns, node)
	if not node or cursor_within(node) then
		return
	end

	local start_row, start_col, end_row, end_col = node:range()

	local line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
	local safe_end_col = math.min(end_col, #line)

	-- 1. Check if the start line has other code before the node
	local start_line_text = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1] or ""
	local prefix = start_line_text:sub(1, start_col)
	local code_before = prefix:gsub("%s*$", "")
	local is_start_clean = (#code_before == 0)
	local adjusted_start_col = #code_before

	-- 2. Check if the end line has other code after the node
	local end_line_text = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1] or ""
	local suffix = end_line_text:sub(end_col + 1)
	local is_end_clean = suffix:match("^%s*$") ~= nil

	-- Define the boundaries for the vertical collapse
	local collapse_start = is_start_clean and start_row or start_row + 1
	local collapse_end = is_end_clean and end_row or end_row - 1

	-- 1. Handle the First Line (Text only, no line collapse)
	vim.api.nvim_buf_set_extmark(buf, ns, start_row, adjusted_start_col, {
		end_row = start_row,
		end_col = (start_row == end_row) and end_col or safe_end_col, -- handle single-line nodes
		conceal = "",
	})

	-- Handle partial start line (if not clean)
	if not is_start_clean then
		vim.api.nvim_buf_set_extmark(buf, ns, start_row, start_col, {
			end_row = start_row,
			end_col = (start_col == end_row) and end_col or safe_end_col,
			conceal = "",
		})
	end

	-- Handle the vertical collapse (The "meat" of the block)
	if collapse_end > collapse_start or (is_start_clean and is_end_clean) then
		vim.api.nvim_buf_set_extmark(buf, ns, collapse_start, 0, {
			end_row = collapse_end,
			conceal_lines = "",
		})
	end

	-- Handle partial end line (if not clean and node spans multiple lines)
	if not is_end_clean and end_row > start_row then
		vim.api.nvim_buf_set_extmark(buf, ns, end_row, 0, {
			end_row = end_row,
			end_col = end_col,
			conceal = "",
		})
	end
end

local function inject_ghost_lang(buf, ns, comment, node, text, lang)
	if vim.wo.conceallevel < 1 or not lang or cursor_within(comment) then
		return
	end

	local start_row, start_col, _, _ = node:range()

	local offset = 1

	if text:find("^''") then
		offset = 2
	end

	local suffix = ""
	if text:sub(offset + 1, offset + 1):match("%s") == nil then
		suffix = ":"
	end

	vim.api.nvim_buf_set_extmark(buf, ns, start_row, start_col + offset, {
		virt_text = { { lang .. suffix, "Comment" } },
		virt_text_pos = "inline",
	})
end

local matches = {}

local function refresh_matches(buf)
	if not is_nix(buf) then
		return
	end

	local query = vim.treesitter.query.parse(
		"nix",
		[[
		;query
		((comment) @code.comment
			[(string_expression) (indented_string_expression)] @code.string)
		]]
	)

	local tree = vim.treesitter.get_parser():parse()[1]

	matches[buf] = {}
	local idx = 1

	for _, match, _ in query:iter_matches(tree:root(), buf) do
		-- id: 1 = code.comment
		-- id: 2 = code.string
		local comment_node = match[1][1]
		local comment_text = vim.treesitter.get_node_text(comment_node, buf)

		local string_node = match[2][1]
		local string_text = vim.treesitter.get_node_text(string_node, buf)

		matches[buf][idx] = {
			comment_node = comment_node,
			comment_text = comment_text,
			string_node = string_node,
			string_text = string_text,
			lang = comment_text:match("%a+"),
		}

		idx = idx + 1
	end
end

local function refresh_extmarks(buf)
	if not is_nix(buf) then
		return
	end
	if not matches[buf] then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	for _, match in ipairs(matches[buf]) do
		conceal_node(buf, ns, match.comment_node)
		inject_ghost_lang(buf, ns, match.comment_node, match.string_node, match.string_text, match.lang)
	end
end

local function enable_autocmds()
	augroup = vim.api.nvim_create_augroup("nix_string_ghost", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave", "Syntax" }, {
		pattern = "*.nix",
		group = augroup,
		callback = function(ev)
			refresh_matches(ev.buf)
			refresh_extmarks(ev.buf)
		end,
	})
	vim.api.nvim_create_autocmd({ "OptionSet" }, {
		pattern = "conceallevel",
		group = augroup,
		callback = function(ev)
			local buf = vim.api.nvim_get_current_buf()
			refresh_extmarks(buf)
		end,
	})
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		pattern = "*.nix",
		group = augroup,
		callback = function(ev)
			vim.defer_fn(function()
				refresh_extmarks(ev.buf)
			end, 0)
		end,
	})
end

function M.setup()
	enable_autocmds()
end

return M
