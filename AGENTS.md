# Agent Guidelines for NixOS Configuration

## Repository Structure
- `hosts/` - Per-host configurations (configuration.nix, hardware-configuration.nix)
- `home/` - Home Manager user configurations
- `common/` - Shared system configuration (unfree packages, experimental features)

## Build/Deploy Commands
- Update flake inputs: `nix flake update`
- Rebuild NixOS system: `sudo nixos-rebuild switch --flake .#mini`
- Rebuild for different host: `sudo nixos-rebuild switch --flake .#hostname`
- Apply Home Manager config: `home-manager switch --flake .#redman`
- Apply for different user: `home-manager switch --flake .#username`

## Code Style
- Language: Nix expressions
- Indentation: 4 spaces (not tabs)
- Imports: Place in `imports = [ ./file.nix ];` block at top of file
- Variables: Use camelCase (e.g., `systemSettings`, `userSettings`)
- Attribute sets: Use `{ }` with consistent spacing
- Lists: Use `[ ]` for arrays, `with pkgs;` for package lists
- Pass system/user settings via `specialArgs` in flake.nix
- No trailing semicolons on closing braces
- Host configs in `hosts/hostname/`, import `../../common/default.nix` and `./hardware-configuration.nix`
- Home configs in `home/`, import other home modules with `./module.nix`

## Testing
- No automated tests; validation done via rebuild
- Test system changes: `sudo nixos-rebuild switch --flake .#mini`
- Test home config: `home-manager switch --flake .#redman`
