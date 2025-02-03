local main = require("dockerenv.main")
local helpers = require("dockerenv.helpers")

local M = {}

M.setup = function()
	vim.api.nvim_create_user_command("LoadDockerEnv", function(data)
		M.load_container_env(data.args)
	end, { desc = "Load a docker environment's lsp packages", nargs = "?" })
end

--- @param containerName string | nil
M.load_container_env = function(containerName)
	if not containerName or containerName == "" then
		local available_containers = helpers.get_available_containers()

		if #available_containers == 0 then
			vim.notify("Nenhum binário exportado!", vim.log.levels.ERROR)
			return false
		end

		helpers.pick(available_containers, "Selecione o container desejado:", function(choice)
			main.load_container_env(choice)
		end)

		return
	end

	main.load_container_env(containerName)
end

return M
