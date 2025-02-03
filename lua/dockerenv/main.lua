local helpers = require("dockerenv.helpers")

local main = {}

--- @type string | nil
local originalPATH = nil

--- @param containerName string
function main.load_container_env(containerName)
	local container_path = helpers.get_container_path(containerName)

	if not vim.uv.fs_stat(container_path) then
		vim.notify(("Container inválido (%s)!"):format(containerName), vim.log.levels.ERROR)
		return false
	end

	if not originalPATH then
		originalPATH = vim.env.PATH
	end

	vim.env.PATH = container_path .. ":" .. originalPATH

	local binaries = helpers.get_container_binaries_as_map(containerName)
	local lspconfig_path = helpers.find_lspconfig_path()
	local configs_path = vim.fs.joinpath(lspconfig_path, "lua", "lspconfig", "configs/")
	local to_be_started_servers = {}

	for name, entryType in vim.fs.dir(configs_path) do
		if entryType == "file" then
			local safe_name = name:gsub("%.lua", "")
			local cfg = require("lspconfig.configs." .. safe_name)

			if cfg.default_config.cmd then
				local cmd = cfg.default_config.cmd

				if type(cmd) == "table" then
					cmd = vim.fs.basename(cmd[1])
				elseif type(cmd) == "string" then
					cmd = vim.fs.basename(cmd)
				else
					cmd = nil
				end

				if binaries[cmd] then
					table.insert(to_be_started_servers, safe_name)
				end
			end
		end
	end

	for _, server in ipairs(to_be_started_servers) do
		vim.schedule(function()
			require("lspconfig")[server].setup({})
		end)
	end
end

return main
