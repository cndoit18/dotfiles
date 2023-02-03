# github.com/cndoit18/dotfiles

Cndoit18's dotfiles, managed with [`chezmoi`](https://github.com/twpayne/chezmoi).

Install them with:

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply cndoit18

Personal secrets are stored in [1Password](https://1password.com) and you'll
need the [1Password CLI](https://developer.1password.com/docs/cli/) installed.
Login to 1Password with:

    eval $(op signin)