#!/bin/sh

PORT_NEW="8090"
PORT_OLD="8000"
IMAGE="ostis/ostis"
VERSION="0.6.0"

# Container paths
OSTIS_PATH="/ostis"
OSTIS_SCRIPTS_PATH="${OSTIS_PATH}/scripts"

# Local paths
APP_PATH=${PWD}
KB_PATH="${APP_PATH}/kb"
PROBLEM_SOLVER_PATH="${APP_PATH}/problem-solver"
SCRIPTS_PATH="${APP_PATH}/scripts"

SCRIPT_FLAGS=""

help()
{
  cat << EOM
This is a tool for running container with OSTIS.

USAGE:
  ./run.sh [OPTIONS]

OPTIONS:
  --help -h         Print help message
  --port -p         Set a custom port for new client
  --port_old        Set a custom port for old client
  --app             Set a custom path to the app directory(By default, it is expected, that inside the app you have all default directories for kb, problem-solver etc)
  --kb              Set a custom path to kb directory
  --solver          Set a custom path to problem-solvers directory
  --compile -c      Compile and run specified program. Usage: --compile <executable name>
  --startflags --sf To set container startup flags(using --all by default). Usage: --startflags "[OSTIS FLAGS]"

OSTIS FLAGS:
  --help -h             Print help message
  --all -a              Run all services
  --sc-mashine --scm    Rebuild sc-machine
  --build_kb --kb       Rebuild kb
  --sc-web --web        Run sc-web only
  --sctp                Run sctp only
EOM
}

for (( i=1; i<=$#; i++))
do
  case "${!i}" in
    --help | -h)
      help
      exit 0
      ;;
    --port | -p)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "Cannot handle empty port value!"
        help
        exit 1
      else
          PORT_NEW="${!j}"
      fi
      ;;
    --port_old)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "Cannot handle empty port value!"
        help
        exit 1
      else
        PORT_OLD="${!j}"
      fi
      ;;
    --app)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "Cannot handle empty app path value!"
        help
        exit 1
      else
        APP_PATH="${!j}"
        KB_PATH="${APP_PATH}/kb"
        PROBLEM_SOLVER_PATH="${APP_PATH}/problem-solver"
      fi
      ;;
    --kb)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "Cannot handle empty kb path value!"
        help
        exit 1
      else
        KB_PATH="${!j}"
      fi
      ;;
    --solver)
        j=$((i+1))
        if [ -z "${!j}" ]
      then
        echo "Cannot handle empty problem-solver path value!"
        help
        exit 1
      else
          PROBLEM_SOLVER_PATH="${!j}"
      fi
      ;;
    --startflags | --sf)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "Cannot handle empty startup flags!"
        help
        exit 1
      else
        SCRIPT_FLAGS="${!j}"
      fi
      ;;
    --compile | -c)
      j=$((i+1))
      if [ -z "${!j}" ]
      then
        echo "No argument given!"
        help
        exit 1
      else
        SCRIPT_FLAGS="-c ${!j}"
      fi
      ;;
    esac
    shift
done

if [ -z "${SCRIPT_FLAGS}" ]
then
  SCRIPT_FLAGS="--all"
fi

docker run -t -i \
  -v ${KB_PATH}:${OSTIS_PATH}/kb \
  -v ${PROBLEM_SOLVER_PATH}:${OSTIS_PATH}/problem-solver \
  -p ${PORT_NEW}:8090 \
  -p ${PORT_OLD}:8000 \
  ${IMAGE}:${VERSION} \
   ${SCRIPT_FLAGS}

exit
