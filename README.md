# dockerenv.nvim

This plugin loads LSPs (using nvim-lspconfig) from a docker container, listing all containers with binaries exported to the following path:

```
~/.local/share/distrobox_exportador/CONTAINER_NAME
```

## Installation

### lazy.nvim

```lua
{
    "mateusrdc/dockerenv.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    cmd = "LoadDockerEnv",
    opts = {}
}
```

## Options

```lua
{
	--- @type "use_mappings" | "inspect_lspconfig"
	binary_mapping_strategy = "use_mappings",

	--- @type { on_attach: function?, on_init: function?, capabilities: table? }?
	lspconfig_setup_options = {} -- The default implementation supports NvChad handlers, if present
}
```

