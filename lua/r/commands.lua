local config = require("r.config").get_config()

local M = {}

local function show_config(tbl)
    local opt = tbl.args
    local out = {}
    if opt and opt:len() > 0 then
        opt = opt:gsub(" .*", "")
        table.insert(out, { vim.inspect(config[opt]) })
    else
        table.insert(out, { vim.inspect(config) })
    end
    vim.schedule(function() vim.api.nvim_echo(out, false, {}) end)
end

local config_keys = {}
for k, _ in pairs(config) do
    table.insert(config_keys, tostring(k))
end

function M.create_user_commands()
    vim.api.nvim_create_user_command(
        "RStop",
        function(_) require("r.run").signal_to_R("SIGINT") end,
        {}
    )
    vim.api.nvim_create_user_command(
        "RKill",
        function(_) require("r.run").signal_to_R("SIGKILL") end,
        {}
    )
    vim.api.nvim_create_user_command("RBuildTags", require("r.edit").build_tags, {})
    vim.api.nvim_create_user_command("RDebugInfo", require("r.edit").show_debug_info, {})
    vim.api.nvim_create_user_command("RMapsDesc", require("r.maps").show_map_desc, {})

    vim.api.nvim_create_user_command(
        "RSend",
        function(tbl) require("r.send").cmd(tbl.args) end,
        { nargs = 1 }
    )

    vim.api.nvim_create_user_command(
        "RFormat",
        require("r.run").formart_code,
        { range = "%" }
    )

    vim.api.nvim_create_user_command(
        "RInsert",
        function(tbl) require("r.run").insert(tbl.args, "here") end,
        { nargs = 1 }
    )

    vim.api.nvim_create_user_command(
        "RSourceDir",
        function(tbl) require("r.run").source_dir(tbl.args) end,
        { nargs = 1, complete = "dir" }
    )

    vim.api.nvim_create_user_command(
        "RHelp",
        function(tbl) require("r.doc").ask_R_help(tbl.args) end,
        {
            nargs = "?",
            complete = require("r.server").list_objs,
        }
    )

    vim.api.nvim_create_user_command("RConfigShow", show_config, {
        nargs = "?",
        complete = function() return config_keys end,
    })

    vim.api.nvim_create_user_command(
        "Roxygenize",
        function() require("r.roxygen").insert_roxygen(vim.api.nvim_get_current_buf()) end,
        {}
    )
end

return M
