# showcolors.nvim

*A Neovim plugin that dynamically displays hex colors in the buffer.*

## **Features:**

* Real-time color change highlighting.

## **Installation:**

Add `leonardo-luz/showcolors.nvim` to your Neovim plugin manager (e.g., in your `init.lua` or `plugins/showcolors.lua`).  For example:

```lua
{ 
    'leonardo-luz/showcolors.nvim',
    opts = {
        active = false
    }
}
```

**The plugin is active by default if the `active` option is set to `true` in the configuration.**

## **Usage:**

* `:Showcolors`: Displays colors in the current buffer.
* `:ShowcolorsStart`: Dynamically displays colors in the current buffer.
* `:ShowcolorsStop`: Stops the dynamic display of colors.
