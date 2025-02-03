local helpers = require("dockerenv.helpers")

local main = {}

--- @type string | nil
local originalPATH = nil

--- @param containerName string
--- @param opts { reload_buffers: boolean }
function main.load_container_env(containerName, opts)
	local container_path = helpers.get_container_path(containerName)

	if not vim.uv.fs_stat(container_path) then
		vim.notify(("Container inválido (%s)!"):format(containerName), vim.log.levels.ERROR)
		return false
	end

	if not originalPATH then
		originalPATH = vim.env.PATH
	end

	vim.env.PATH = container_path .. ":" .. originalPATH

	for _, server in ipairs(main.get_available_servers(containerName)) do
		vim.schedule(function()
			require("lspconfig")[server].setup({})
		end)
	end

	if opts.reload_buffers then
		for _, bufid in pairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(bufid) then
				if vim.api.nvim_get_option_value("modifiable", { buf = bufid }) then
					vim.schedule(function()
						vim.api.nvim_buf_call(bufid, function()
							vim.cmd({ cmd = "edit", bang = true })
						end)
					end)
				end
			end
		end
	end
end

--- @param containerName string
--- @return string[]
function main.get_available_servers(containerName)
	local binaries = helpers.get_container_binaries_as_map(containerName)
	local lspconfig_path = helpers.find_lspconfig_path()
	local configs_path = vim.fs.joinpath(lspconfig_path, "lua", "lspconfig", "configs/")
	local result = {} --- @type string[]

	for name, entryType in vim.fs.dir(configs_path) do
		if entryType == "file" then
			local safe_name = name:gsub("%.lua", "")
			local ok, cfg = pcall(require, "lspconfig.configs." .. safe_name)

			if ok and cfg.default_config.cmd then
				local cmd = cfg.default_config.cmd

				if type(cmd) == "table" then
					cmd = vim.fs.basename(cmd[1])
				elseif type(cmd) == "string" then
					cmd = vim.fs.basename(cmd)
				else
					cmd = nil
				end

				if binaries[cmd] then
					table.insert(result, safe_name)
				end
			end
		end
	end

	return result
end

return main
