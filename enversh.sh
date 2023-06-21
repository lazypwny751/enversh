#!/bin/bash

#    a sample fake environment manager for entre different distributions - enversh.sh
#    Copyright (C) 2023  lazypwny751
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# https://tr.wikipedia.org/wiki/Enver_Paşa
#
# TODO:
#   Allah kerimdir, belki gelecekte daha hızlı ve sağlıklı olması açısından
#   jq yerine awk ile kendimiz bir parser yazarız ve bunu kullanarak
#   paketler için precheckup özelliği getiririz.

# Pre defaults and set exit on fail. 
set -e
export status="true" method="soft" require="false" force="false" version="1.0.0" ENVD="/tmp/enversh" CWD="${PWD}" OPTARG=()
if [[ -f "/etc/os-release" ]] ; then
    source "/etc/os-release"
elif [[ -n "${ID}" ]] ; then
    true # also we can use ":".
else
    echo "there isn't any os-release file or definied \$ID variable!"
    exit 1
fi

# Functions
check:cmd() {
    local i="" status="true"
    for i in "${@}" ; do
        if ! command -v "${i}" &> /dev/null ; then
            echo "${0##*/}: ${FUNCNAME##*:}: command not found \"${i}\"!"
            local status="false"
        fi
    done

    if ! "${status}" ; then
        return 1
    fi
}

pkg:wrapper() {
    # This function require root privalages.
    # TODO:
    #
    #   - Add Fedora, OpenSUSE (might be emerge)
    #   - Add pip, npm, gem.

    if [[ -n "${@}" ]] ; then
        case "${ID,,}" in
            "ubuntu"|"debian"|"linuxmint")
                apt update && apt install -y "${@}"
            ;;
            "arch"|"pnm"|"manjaro")
                pacman -Sy --noconfirm "${@}"
            ;;
        esac
    fi
}

# Argument&Parameter parsing.
while [[ "${#}" -gt 0 ]] ; do
    case "${1}" in
        "--"[sS][oO][fF][tT])
            export method="soft"
            shift
        ;;
        "--"[hH][aA][rR][dD])
            export method="hard"
            shift
        ;;
        "--"[fF][oO][rR][cC][eE])
            export force="true"
            shift
        ;;
        "--"[rR][eE][qQ][uU][iI][rR][eE])
            export require="true"
            shift
        ;;
        "--"[pP][aA][tT][hH])
            shift
            if [[ -n "${1}" ]] ; then
                export ENVD="${1}"
                shift
            fi
        ;;
        "--"[vV][eE][rR][sS][iI][oO][nN])
            export DO="version"
            shift
        ;;
        *)
            export OPTARG+=("${1}")
            shift
        ;;
    esac
done

if [[ -n "${OPTARG[@]}" ]] ; then
    export DO="env"
else
    export DO="help"
fi

# Main case
case "${DO}" in
    "env")
        # Check the required commands.
        check:cmd "jq" "ln" "mkdir" "chmod"

        # Check the os base if available for the show.
        if [[ -z "${ID}" ]] && [[ -f "/etc/os-release" ]] ; then
            source "/etc/os-release"
        fi

        if [[ -z "${ID}" ]] ; then
            echo "${0##*/}: unknown distribution base."
            exit 1
        fi

        # Check if available.
        case "${ID}" in
            "linuxmint"|"ubuntu"|"debian"|"arch")
                # Setup the environment path directory.
                if [[ ! -d "${ENVD}" ]] ; then
                    mkdir -p "${ENVD}"
                fi

                for f in "${OPTARG[@]}" ; do
                    if [[ -f "${f}" ]] ; then
                        # For all elements in json array.
                        if [[ "$(jq -r ".${ID,,}" "${f}")" != "null" ]] ; then
                            if "${require}" ; then
                                pkg:wrapper $(jq -r ".${ID,,}[].package" "${f}")
                            fi
                            for ((el="0" ; el<"$(jq ".${ID,,} | length" "${f}")" ; el++)) ; do
                                export command="$(jq -r ".${ID,,}[${el}].command" "${f}")" export="$(jq -r ".${ID,,}[${el}].export" "${f}")"
                                if command -v "${command}" &> /dev/null ; then
                                    if [[ "${method}" = "soft" ]] ; then
                                        ln -fs "$(command -v "${command}")" "${ENVD}/${export}"
                                    elif [[ "${method}" = "hard" ]] ; then
                                        ln -f "$(command -v "${command}")" "${ENVD}/${export}"
                                    fi
                                else
                                    if "${force}" ; then
                                        echo -e "#!/bin/bash\n\necho \"null\"" > "${ENVD}/${export}"
                                        chmod u+x "${ENVD}/${export}"
                                    else
                                        echo "${0##*/}: ${command}: command not found!"
                                        export status="false"
                                    fi
                                fi
                            done
                        else
                            echo "${0##*/}: \"${f}\" doesn't have any supported environment."
                            break
                        fi
                    fi
                done

                if ! "${status}" ; then
                    exit 1
                fi
            ;;
            *)
                echo "${0##*/}: unsupported distribution!"
                exit 1
            ;;
        esac
    ;;
    "help")
        echo -e "Why we need \"${0##*/}\", Although rare, the environment 
elements may vary between different distributions,
so a virtual environment that you will prepare 
in json format is configured to be adjusted in
the distributions you specify, and it will also
bring the packages you specify.

usage of ${0##*/}, there is 7 arguments:
bash ${0##*/} --soft:
\tthis is the default linking method of ${0##*/},
\tit links all the exports as soft link.
bash ${0##*/} --hard:
\tthis method links all the exports as hard link but
\tit could be required root privalages.
bash ${0##*/} --force:
\tif any command not found, replace it with any null bash script.
bash ${0##*/} --require:
\tinstall all of packages that given file via supported distributions.
bash ${0##*/} --path <path>:
\tset the current path directory, it will be created if doesn't exist
\tand all the exports goes there.
bash ${0##*/} --help:
\tshow's this helper output.
bash ${0##*/} --version: 
\tshow's current version of the script (${version})."
    ;;
    "version")
        echo "${version}"
    ;;
esac