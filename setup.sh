#!/bin/bash

# Enable debug if argument passed to script
if [[ "${1}" =~ debug ]]; then
	set -x
fi

# Check for dependencies
DEPS=""
type git &>/dev/null || DEPS="  git\n"

if [[ -n "${DEPS}" ]] ; then
	echo "Please install missing dependencies:"
	echo -e "${DEPS}"
	exit 1
fi

# Fail the whole script if one part fails
set -eo pipefail
finish() {
	if [[ $? -ne 0 ]]; then
		set +x
		echo -e "\nSorry, something went wrong. Try running with debug, i.e.:"
		echo -e "  ${0} --debug\n"
	fi
}
trap finish EXIT

# Directory containing the script, so that we can copy other files out
DIR="$(dirname "$(readlink -f "${0}")")"

# Get tpm (tmux plugin manager)

mkdir -p "${HOME}/.tmux/plugins/"
if [[ -d "${HOME}/.tmux/plugins/tpm/.git" ]]; then
	( cd "${HOME}/.tmux/plugins/tpm"
	echo "Pulling tpm updates from GitHub"
	git pull origin master &>/dev/null
	cd - >/dev/null )
else
	echo "Cloning tpm from GitHub"
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm" &>/dev/null
fi

# Put our tmux.conf in place
echo "Installing tmux config"
cp "${DIR}/tmux.conf" "${HOME}/.tmux.conf"
tmux source ~/.tmux.conf:q

# Install all the plugins specified in .tmux.conf (or in tmux <prefix> + I)
tmux -C run-shell ~/.tmux/plugins/tpm/bindings/install_plugins

# Advise user of overrides
cat << EOF
All done!
EOF
