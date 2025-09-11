if vim.g.loaded_ansillary then
  return
end
vim.g.loaded_ansillary = 1

vim.api.nvim_create_user_command("AnsillaryToggle", function()
  require("ansillary").toggle()
end, {
  desc = "Toggle ANSI highlighting and concealment on/off completely"
})

vim.api.nvim_create_user_command("AnsillaryToggleConceal", function()
  require("ansillary").toggle_conceal()
end, {
  desc = "Toggle ANSI code concealment (keep highlighting active)"
})

vim.api.nvim_create_user_command("AnsillaryToggleReveal", function()
  require("ansillary").toggle_reveal()
end, {
  desc = "Toggle revealing ANSI codes under cursor"
})

vim.api.nvim_create_user_command("AnsillaryToggleText", function()
  require("ansillary").toggle_text_highlights()
end, {
  desc = "Toggle highlighting of text content based on ANSI codes"
})

vim.api.nvim_create_user_command("AnsillaryToggleANSI", function()
  require("ansillary").toggle_ansi_highlights()
end, {
  desc = "Toggle highlighting of ANSI escape sequences"
})
