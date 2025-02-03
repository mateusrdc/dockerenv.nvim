--- @class Config
local default_options = {
	--- @type { on_attach: function?, on_init: function?, capabilities: table? }?
	lspconfig_setup_options = (function()
		local is_nvchad, nvlsp = pcall(require, "nvchad.configs.lspconfig")

		if is_nvchad then
			return { on_attach = nvlsp.on_attach, on_init = nvlsp.on_init, capabilities = nvlsp.capabilities }
		else
			return nil
		end
	end)(),
}

return default_options
