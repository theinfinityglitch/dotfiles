# Changes this session

## ly not listing Hyprland, cursor offset, shell/xinitrc login errors
Root cause: `ly` was being launched as a bare command *inside* `greetd`
(`services.greetd.settings.default_session.command = "${pkgs.ly}/bin/ly"`).
`ly` is a standalone display manager with its own PAM service, TTY/VT
handling, and session-discovery mechanism -- it isn't meant to run as a
"greeter command" nested inside a different display manager. Running it
this way meant:

- It never received `services.displayManager.sessionPackages` (where
  `programs.hyprland.enable` normally registers the Hyprland session
  automatically), so it fell back to its hardcoded generic options
  (`shell`, `xinitrc`).
- It had no properly-configured PAM service of its own, hence the login
  errors when selecting either fallback option.
- The nested VT/greeter hand-off is the likely source of the cursor
  offset glitch.

Fix:
- `modules/nixos/security.nix`: removed the `services.greetd` block entirely.
- `modules/nixos/desktop.nix`: added `services.displayManager.ly.enable = true;`
  -- the dedicated NixOS module. This automatically picks up the Hyprland
  session since `programs.hyprland.enable` already adds itself to
  `services.displayManager.sessionPackages`.

After rebuilding, `ly` should list "Hyprland" as a session option directly.

## Vicinae stopped autostarting (works only when launched manually)
**Correction**: I initially (wrongly) guessed the vicinae flake had renamed `programs.vicinae` to `services.vicinae` and made that change -- it hadn't; that option doesn't exist and broke the build (`error: The option 'home-manager.users.themaster.services.vicinae' does not exist`). Reverted back to `programs.vicinae`, which was correct all along.

Real root cause: a still-open upstream race condition ([vicinaehq/vicinae#341](https://github.com/vicinaehq/vicinae/issues/341)). `vicinae.service` starts as soon as `graphical-session.target` is reached, but the Wayland session isn't always fully ready yet -- it connects, then gets `"The Wayland connection broke. Did the Wayland compositor die?"` a few seconds later and exits with no retry. That's exactly why it only ever worked when started manually afterward (by then the session had settled) and never automatically at boot. No upstream fix exists yet.

Fix (workaround, since there's no real fix to apply): `modules/home/programs.nix` — first tried adding `Restart = "on-failure"`, but that conflicted with the module's own `Restart = "always"` (build error: conflicting definition values). Since the module already retries on any exit, the actual gap was systemd's default restart-rate limit (5 restarts per 10s) — likely getting hit and giving up before the session settles. Fixed by raising it instead: `systemd.user.services.vicinae.Unit = { StartLimitIntervalSec = 30; StartLimitBurst = 10; };`. This adds a new section/keys rather than touching `Service.Restart`, so no conflict with the module's own definition.


