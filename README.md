# Idk what to put here yet

This is my restart on ricing my desktop. Now based on Niri with a custom base16 color palette.

**Note**: This is my personal configuration. Which means that I use on my own daily desktop.

## Colors

### Bas16 palette

![palette](./assets/palette.svg)

### Some helper colors

| Color | Role |
| :--- | :--- |
| Main background | `#05070A` |
| Secondary background | `#090D12` |
| Panels / surfaces | `#101720` |
| Borders | `#19232E` |
| Main accent | `#00A5FF` |
| Secondary accent | `#59B9F5` |
| Main text | `#C5CDD6` |
| Muted text | `#758393` |

## How it's configured

I symlinked the configs stored on the [configs](./configs) to the respective paths on the `~/.config`. For example, for kitty:

```bash
ln -Tsf $PWD/configs/kitty ~/.config/kitty
```

On my machine, I use the Helix from the master branch. To have access to the themes and other stuff from the helix runtime, I had to symlink the runtime too, so the [runtime](./configs/helix/runtime) may be broken when you or me use on a new machine or that wasn't configured for it yet. If you are using the Helix from the master branch too, you need to clone and symlink it:

```bash
git clone --depth 1 https://github.com/helix-editor/helix.git
cd helix
ln -Tsf $PWD/runtime ~/.config/helix/runtime
```
