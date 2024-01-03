local pattern = [[\b*<(KEYWORDS)\b?:?]]

require("todo-comments").setup {
	keywords = {
		MUDO = {
			icon = " ",
			color = "error", 
		},
	},
	highlight = {
		pattern = pattern,
		keyword = "bg",
	},
	search = {
		pattern = pattern,
	},
}
