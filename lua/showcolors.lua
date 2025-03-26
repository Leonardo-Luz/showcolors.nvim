local state = {
  bufread_id = nil,
  insertchar_id = nil,
  active = false,
}

local M = {}

local function hex_to_decimal(hex_str)
  hex_str = string.gsub(hex_str, "^#", "")

  if string.len(hex_str) ~= 6 then
    return nil, "Invalid hex string length"
  end

  local r = tonumber(string.sub(hex_str, 1, 2), 16)
  local g = tonumber(string.sub(hex_str, 3, 4), 16)
  local b = tonumber(string.sub(hex_str, 5, 6), 16)

  if r == nil or g == nil or b == nil then
    return nil, "Invalid hex characters"
  end

  return r, g, b
end

local function sum_hex_color(hex_color_str)
  local r, g, b, err = hex_to_decimal(hex_color_str)
  if err then
    print("Error processing hex color: " .. err)
    return nil
  end
  return r + g + b
end

M.show_colors = function()
  local id = vim.api.nvim_create_namespace("showcolor")
  local buf = vim.api.nvim_get_current_buf()

  local start_line = 0
  local end_line = vim.api.nvim_buf_line_count(buf)

  for line_num = start_line, end_line - 1 do
    local map_line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]

    local start_col, end_col = string.find(map_line,
      "#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]")

    if not start_col or not end_col then
      goto continue
    end

    local color = map_line:sub(start_col, end_col)
    local hl_group = string.format("Color%d%d%d", line_num, start_col, end_col)
    local font_color = sum_hex_color(color) >= 459 and "black" or "white"

    local command = string.format("highlight %s guibg=%s guifg=%s", hl_group, color, font_color)
    vim.cmd(command)

    vim.api.nvim_buf_set_extmark(buf, id, line_num, start_col, {
      hl_group = hl_group,
      end_col = end_col,
    })

    ::continue::
  end
end

M.hide_colors = function()
  local buf = vim.api.nvim_get_current_buf()
  local start_line = 0
  local end_line = vim.api.nvim_buf_line_count(buf)

  for line_num = start_line, end_line - 1 do
    local map_line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]
    local start_col, end_col = string.find(map_line,
      "#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]")

    if not start_col or not end_col then
      goto continue
    end

    local hl_group = string.format("Color%d%d%d", line_num, start_col, end_col)

    local command = string.format("highlight clear %s", hl_group)
    vim.cmd(command)
    ::continue::
  end
end

M.stop = function()
  M.hide_colors()

  if state.bufread_id then
    vim.api.nvim_del_autocmd(state.insertchar_id)
    vim.api.nvim_del_autocmd(state.bufread_id)

    state.bufread_id = nil
    state.insertchar_id = nil
  end
end

M.start = function()
  M.stop()
  M.show_colors()

  if not state.bufread_id then
    state.bufread_id = vim.api.nvim_create_autocmd("BufReadPost", {
      callback = function()
        M.hide_colors()
        M.show_colors()
      end,
    })
    state.insertchar_id = vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      callback = function()
        M.hide_colors()
        M.show_colors()
      end,
    })
  end
end

M.setup = function(opts)
  state.active = opts.active
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if state.active then
      M.start()
    end
  end,
})

vim.api.nvim_create_user_command("Showcolors", function()
  M.show_colors()
end, {})

vim.api.nvim_create_user_command("ShowcolorsStart", function()
  M.start()
end, {})

vim.api.nvim_create_user_command("ShowcolorsStop", function()
  M.stop()
end, {})

return M
