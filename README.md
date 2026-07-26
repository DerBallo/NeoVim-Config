# NeoVim-Config
My personal neovim config

## Keybinds

Each keybind works in one or more modes:
"n" = Normal mode
"i" = Insert mode
"v" and "x" = Visual (select) mode
"t" = Terminal mode

- "<Esc>" in "n": enter insert mode
- "<Esc>" in "t": return to normal mode
* "<Alt><Up>" in "n" and "v": move the current line or selection up one line
* "<Alt><Down>" in "n" and "v": move the current line or selection down one line
* "<Space>e" in "n": open the file explorer in the current window split
* "<Space>t" in "n": open a terminal inside the current window split
* "<Space>r" in "n": select and run a shell or batch script from the cwd in the current window split
* "<Space>z" in "n": close the current terminal buffer and return to the previous buffer in the same window split
* "<Space>w" in "n": save the current buffer
* "<Space>q" in "n": close current buffer / quit Neovim
* "<Space>b" in "n": find and switch between buffers
* "<Space>y" in "n", "v" and "x": copy the selection to the system clipboard
* "<Space>f" in "n": format the current buffer
* "<Space>i" in "n": toggle inlay hints
* "<Tab>" in "n": show symbol hover information
* "<Space>m" in "n": search for text in buffers
* "<Space>S" in "n": search for LSP symbols in the workspace
* "<Space>s" in "n": search for files
* "<Space><Space>" in "n": show diagnostics for the current line
* "<Space>o" in "n": search and navigate diagnostics
* "<Enter>" in "n": open LSP actions menu
* "<Space>lll" in "n": paste the contents of "LICENSE.md" in the cwd as a C-style comment
