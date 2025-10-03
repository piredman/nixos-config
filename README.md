# My NixOS Setup

## System Configuration

Update system packages:

```bash
> nix flake update
```

Update system: 

```bash
> sudo nixos-rebuild switch --flake .
```

Update system for alternate host: 

```bash
> sudo nixos-rebuild switch --flake .#host-name
```

## Home Manager Configuraion

Update user config: 

```bash
> home-manager switch --flake .
```

Update user config for alternate user: 

```bash
> home-manager switch --flake .#user-name
```

Rollback config:

```bash
> home-manger generations

# output
2025-10-03 07:35 : id 5 -> /nix/store/i240y16jblsipy8dq5lnma8xszck8a2q-home-manager-generation
2025-10-03 07:30 : id 4 -> /nix/store/41v7pax83lby5c098j79g3lmmlrn6j6m-home-manager-generation
2025-10-03 07:14 : id 3 -> /nix/store/5cw3gzwg23pxj6qr4kjnn9n3s1zmcglr-home-manager-generation
2025-10-03 07:03 : id 2 -> /nix/store/vs70g9skjfpp9wc9rvilwig886zjgwk2-home-manager-generation
2025-10-03 07:00 : id 1 -> /nix/store/q60wzwh0nxp8bb5562fazngx2ljclq1m-home-manager-generation

# use the generation path + /activate, so for id 4:
> /nix/store/41v7pax83lby5c098j79g3lmmlrn6j6m-home-manager-generation/activate
```

