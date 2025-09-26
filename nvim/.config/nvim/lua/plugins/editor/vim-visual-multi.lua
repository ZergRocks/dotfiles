return {
  "mg979/vim-visual-multi",
  lazy = false,
  config = function()
    vim.cmd([[
      let g:VM_maps = {}
      let g:VM_maps['Find Under'] = '<C-n>'
      let g:VM_maps['Find Subword Under'] = '<C-n>'
      let g:VM_mouse_mappings = 0
      let g:VM_theme = 'ocean'
    ]])
  end,
}