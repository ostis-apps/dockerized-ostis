#!/bin/sh

PORT="8000"
IMAGE="ostis/clion-remote-cpp-env"
VERSION="0.6.0"

# Container paths
OSTIS_PATH="/ostis"
OSTIS_SCRIPTS_PATH="${OSTIS_PATH}/scripts"

# Local paths
APP_PATH=${PWD}/..
KB_PATH="${APP_PATH}/kb"
PROBLEM_SOLVER_PATH="${APP_PATH}/problem-solver"
SCRIPTS_PATH="${PWD}/scripts"

SCRIPT_FLAGS=""
DEFAULT_FLAGS="--build_kb --sc-web"

help()
{
  cat << EOM
This is a tool for running clion OSTIS debug container container.
USAGE:
  ./run.sh [OPTIONS]
OPTIONS:
  --help -h         Print help message
  --port -p         Set a custom port
  --app             Set a custom path to the app directory(By default, it is expected, that inside the app you have all default directories for kb, problem-solver etc)
  --kb              Set a custom path to kb directory
  --solver          Set a custom path to problem-solvers deirectory
  --startflags --sf To set container startup flags(using ${DEFAULT_FLAGS} by default). Usage: --startflags "[OSTIS FLAGS]" (quotes are necessary for multiple flags!)
OSTIS FLAGS:
  --help -h             Print help message
  --all -a              Run all services
  --sc-mashine --scm    Rebuild sc-machine
  --build_kb --kb       Rebuild kb
  --sc-web --web        Run sc-web only
  --sctp                Run sctp only
EOM
}

while [ $# -ne 0 ]
do
  case "$1" in
    --help | -h)
      help
      exit 0
      ;;
    --port | -p)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty port value!"
        help
        exit 1
      else
        PORT="$2"
      fi
      ;;
    --app)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty app path value!"
        help
        exit 1
      else
        APP_PATH="$2"
        KB_PATH="${APP_PATH}/kb"
        PROBLEM_SOLVER_PATH="${APP_PATH}/problem-solver"
      fi
      ;;
    --kb)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty kb path value!"
        help
        exit 1
      else
        KB_PATH="$2"
      fi
      ;;
    --solver)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty problem-solver path value!"
        help
        exit 1
      else
        PROBLEM_SOLVER_PATH="$2"
      fi
      ;;
    --startflags | --sf)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty startup flags!"
        help
        exit 1
      else
        SCRIPT_FLAGS="$2"
      fi
    esac
    shift
done

if [ -z "${SCRIPT_FLAGS}" ]
then
  SCRIPT_FLAGS=${DEFAULT_FLAGS}
fi

docker run -it --cap-add sys_ptrace -p127.0.0.1:2222:22 --name clion_remote_env \
  -v ${KB_PATH}:${OSTIS_PATH}/kb \
  -v ${PROBLEM_SOLVER_PATH}:${OSTIS_PATH}/problem-solver \
  -p ${PORT}:8000 \
  ${IMAGE}:${VERSION} \
  sh -c "${OSTIS_SCRIPTS_PATH}/ostis ${SCRIPT_FLAGS} & \
  /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config_test_clion"

exit

