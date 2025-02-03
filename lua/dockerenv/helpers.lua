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
	for _, v in pairs(vim.opt.rtp:get()) do
		if v:match("/nvim%-lspconfig") then
			return v
		end
	end
end

return helpers
