# ImmortalWrt-CI-XG-040G-MD-UBI

GitHub Actions cloud build for **Nokia XG-040G-MD** using the **ImmortalWrt `airoha/an7581` all-in-UBI profile**.

## Target

- Source: `immortalwrt/immortalwrt`
- Branch: `master`
- Target: `airoha`
- Subtarget: `an7581`
- Device: `nokia_xg-040g-md-ubi`
- Upgrade image: `*-nokia_xg-040g-md-ubi-squashfs-sysupgrade.itb`

## Important

This repository targets the **UBI layout** used after migrating the device with a compatible OpenWrt U-Boot / MedveFlasher setup.

Do **not** flash the generated `.itb` directly onto:

- stock Nokia firmware;
- the legacy `nokia_xg-040g-md` layout;
- a tcboot/factory layout that has not been migrated to `nokia_xg-040g-md-ubi`.

Before flashing, verify on the router:

```sh
ubus call system board
```

The board should identify as the UBI variant.

## Build

Open **Actions → Build ImmortalWrt XG-040G-MD UBI → Run workflow**.

The workflow:

1. clones current ImmortalWrt `master`;
2. installs feeds;
3. applies `config/xg040g-md-ubi.config`;
4. runs `make defconfig`;
5. builds the firmware;
6. uploads only the XG-040G-MD UBI sysupgrade image and checksums.

## Repository layout

```text
.github/workflows/build.yml
config/xg040g-md-ubi.config
scripts/customize.sh
README.md
```

## Customization

Add package selections to `config/xg040g-md-ubi.config`.

Use `scripts/customize.sh` for source-tree changes that cannot be expressed as normal Kconfig package selections.

The first version intentionally stays close to upstream ImmortalWrt so that flash-layout and NAND troubleshooting are not mixed with unrelated package changes.
