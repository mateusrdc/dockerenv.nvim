local main = require("dockerenv.main")
local helpers = require("dockerenv.helpers")
local config = require("dockerenv.config")

local M = {}

--- @param opts Config?
M.setup = function(opts)
	config.value = vim.tbl_deep_extend("force", config, opts or {})

	vim.api.nvim_create_user_command("LoadDockerEnv", function(data)
		M.load_container_env(data.args)
	end, { desc = "Load a docker environment's lsp packages", nargs = "?" })
end

--- @param containerName string | nil
M.load_container_env = function(containerName)
	local actual_main = function(choice)
		local reload_buffers = false
		if helpers.any_file_loaded() then
			if helpers.has_unsaved_changes() then
				vim.ui.input(
					{ prompt = "Recarregar todos os buffers? As alterações não salvas serão perdidas (S/n): " },
					function(input)
						reload_buffers = input:lower() == "s" or input:lower() == "y" or input == ""
					end
				)
			else
				reload_buffers = true
			end
		end

		main.load_container_env(choice, { reload_buffers = reload_buffers })
	end

	if not containerName or containerName == "" then
		local available_containers = helpers.get_available_containers()

		if #available_containers == 0 then
			vim.notify("Nenhum binário exportado!", vim.log.levels.ERROR)
			return false
		end

		helpers.pick(available_containers, "Selecione o container desejado:", function(choice)
			actual_main(choice)
		end)

		return
	end

	actual_main(containerName)
end

return M
