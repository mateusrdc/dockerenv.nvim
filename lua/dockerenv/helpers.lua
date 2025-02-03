local helpers = {}

--- @param options string[]
--- @param prompt string
--- @param callback function(string)
function helpers.pick(options, prompt, callback)
	-- Try to use telescope first
	local ok, pickers = pcall(require, "telescope.pickers")

	if ok then
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		pickers
			.new({}, {
				prompt_title = prompt,
				finder = finders.new_table({ results = options }),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)

						local selection = action_state.get_selected_entry()

						callback(selection[1])
					end)

					return true
				end,
			})
			:find()
	else
		-- Use the default vim picker if telescope isn't installed
		vim.ui.select(options, { prompt = prompt }, callback)
	end
end

--- @return string[]
function helpers.get_available_containers()
	local root_dir = vim.fs.normalize("~/.local/share/distrobox_exportador")

	if not vim.uv.fs_stat(root_dir) then
		return {}
	end

	local directories = {}

	for name, entryType in vim.fs.dir(root_dir) do
		if entryType == "directory" then
			table.insert(directories, name)
		end
	end

	return directories
end

--- @param containerName string
--- @return string
function helpers.get_container_path(containerName)
	return vim.fs.normalize(vim.fs.joinpath("~/.local/share/distrobox_exportador/", containerName))
end

--- @param containerName string
--- @return table<string,boolean>
function helpers.get_container_binaries_as_map(containerName)
	local dir = vim.fs.normalize(vim.fs.joinpath("~/.local/share/distrobox_exportador/", containerName))

	if not vim.uv.fs_stat(dir) then
		return {}
	end

	local result = {}

	for name, entryType in vim.fs.dir(dir) do
		if entryType == "file" then
			result[name] = true
		end
	end

	return result
end

function helpers.find_lspconfig_path()
	-- check if lazy.nvim is installed in the default path
	local lazy_nvim_default_path = vim.fn.stdpath("data") .. "/lazy"

	if vim.fn.isdirectory(lazy_nvim_default_path) == 1 then
		for fileName, type in (vim.fs.dir(lazy_nvim_default_path)) do
			if fileName == "nvim-lspconfig" and type == "directory" then
				return vim.fs.joinpath(lazy_nvim_default_path, fileName)
			end
		end
	end

	-- search import paths
	-- this is more error prone as lspconfig may not be loaded yet
	for _, v in pairs(vim.opt.rtp:get()) do
		if v:match("/nvim%-lspconfig") then
			return v
		end
	end
end

--- @return boolean
function helpers.any_file_loaded()
	for _, bufid in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufid) then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufid })

			if buftype ~= "nofile" then
				return true
			end
		end
	end

	return false
end

--- @return boolean
function helpers.has_unsaved_changes()
	for _, bufid in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufid) then
			local modified = vim.api.nvim_get_option_value("modified", { buf = bufid })

			if modified then
				return true
			end
		end
	end

	return false
end

return helpers
