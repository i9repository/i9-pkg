#!/usr/bin/env bash

## prevent sourcing
if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
  echo >&2 "error: \`i9-pkg' cannot be sourced"
  return 1
fi

## i9-pkg version
VERSION="0.0.1"

## output error to stderr
error () {
  printf >&2 "error: %s\n" "${@}"
}

## output usage
usage () {
  echo ""
  echo "  usage: i9-pkg [-hV] <command> [args]"
  echo ""
}

## commands
commands () {
  i9-pkg-suggest 'i9-pkg-' 2>/dev/null |
    tail -n+2                      |
    sed 's/.*\/i9-pkg-//g'           |
    sort -u                        |
    tr '\n' ' '
  return $?
}

## feature tests
features () {
  local features
  declare -a features=(i9-pkg-json i9-pkg-suggest)
  for ((i = 0; i < ${#features[@]}; ++i)); do
    local f="${features[$i]}"
    if ! type "${f}"  > /dev/null 2>&1; then
      error "Missing \"${f}\" dependency"
      return 1
    fi
  done
}

i9-pkg () {
  local arg="$1"
  local cmd=""
  shift

  ## test for required features
  features || return $?

  case "${arg}" in

    ## flags
    -V|--version)
      echo "${VERSION}"
      return 0
      ;;

    -h|--help)
      usage
      echo
      echo "Here are some commands available in your path:"
      echo
      local cmds=($(commands))
      for cmd in "${cmds[@]}"; do
        echo "    ${cmd}"
      done
      return 0
      ;;

    *)
      if [ -z "${arg}" ]; then
        usage
        return 1
      fi
      cmd="i9-pkg-${arg}"
      if type -f "${cmd}" > /dev/null 2>&1; then
        "${cmd}" "${@}"
        return $?
      else
        echo >&2 "error: \`${arg}' is not a i9-pkg command."
        {
          local res
          declare -a res=($(commands))

          if [ -n "${res[*]}" ]; then
            echo
            echo  >&2 "Did you mean one of these?"
            found=0
            for r in "${res[@]}"; do
              if [[ "$r" == *"${arg}"* ]]; then
                echo "     $ i9-pkg ${r}"
                found=1
              fi
            done
            if [ "$found" == "0" ]; then
              for r in "${res[@]}"; do
                echo "     $ i9-pkg ${r}"
              done
            fi
            return 1
          else
            usage
            return 1
          fi
        }
      fi
      ;;

  esac
  usage
  return 1
}

i9-pkg "${@}"
exit $?
