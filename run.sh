#!/bin/sh

PORT="8000"
IMAGE="ostis"
VERSION="scp_stable"

# Container paths
OSTIS_PATH="/ostis"

# Lacal paths
PROJECT_PATH=${PWD}
KB_PATH="${PROJECT_PATH}/kb"
PROBLEM_SOLVER_PATH="${PROJECT_PATH}/problem-solver"

help()
{
  cat << EOM
This is a tool for running container with OSTIS.

USAGE:
  ./run.sh [OPTIONS]

OPTIONS:
  --help -h    Print help message
  --port -p    Set a custom port(CURRENTLY DOES'NT WORKS!!!)
  --project    Set a custom path to the project directory(By default, it is expected, that inside the project you have all default directories for kb, problem-solver etc)
  --kb         Set a custom path to kb directory
  --solver     Set a custom path to problem-solvers deirectory
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
    --project)
      if [ -z "$2" ]
      then
        echo "Cannot handle empty project path value!"
        help
        exit 1
      else
        PROJECT_PATH="$2"
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
    esac
    shift
done

docker run -t -i \
  -v ${KB_PATH}:${OSTIS_PATH}/custom-kb \
  -v ${PROBLEM_SOLVER_PATH}:${OSTIS_PATH}/problem-solver \
  -p ${PORT}:8000 \
  ${IMAGE}:${VERSION}

exit

