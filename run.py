import os
import argparse

PORT_NEW = "8090"
PORT_OLD = "8000"
IMAGE = "ostis/ostis"
VERSION = "0.6.0"

# Container paths
OSTIS_PATH = "/ostis"
OSTIS_SCRIPTS_PATH = f"{OSTIS_PATH}/scripts"

# Local paths
APP_PATH = os.getcwd()
KB_PATH = f"{APP_PATH}/kb"
PROBLEM_SOLVER_PATH = f"{APP_PATH}/problem-solver"
SCRIPTS_PATH = f"{APP_PATH}/scripts"

def help():
    print('''
    This is a CLI for ostis

    OPTIONS:
    help, h             Print help message
    all, a              Run all services
    sc-mashine, m       Rebuild sc-machine
    build_kb, kb        Rebuild kb
    sc-web, web         Run sc-web only
    sctp                Run sctp only
    compile, c          Compile and run specified program. Usage: --compile <executable name>
    quit, q             Stop running container
    ''')


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description = 'This is a tool for running container with OSTIS.')
    parser.add_argument('-v', '--version', action='version', version='ostis 0.6.0', help = 'Show version of program')
    parser.add_argument('-p', '--port', help = 'Set a custom port for new client')
    parser.add_argument('--port_old', help = 'Set a custom port for old client')
    parser.add_argument('--app', help = 'Set a custom path to the app directory (By default, it is expected, that inside the app you \
            have all default directories for kb, problem-solver etc)')
    parser.add_argument('--kb', help = 'Set a custom path to kb directory')
    parser.add_argument('--solver', help = 'Set a custom path to problem-solvers directory')

    args = parser.parse_args()
    
    if args.port:
        PORT_NEW = args.port
    if args.port_old:
        PORT_OLD = args.port_old
    if args.app:
        APP_PATH = args.app
        KB_PATH = f"{APP_PATH}/kb"
        PROBLEM_SOLVER_PATH = f"{APP_PATH}/problem-solver"
    if args.kb:
        KB_PATH = args.kb
    if args.solver:
        PROBLEM_SOLVER_PATH = args.solver

    os.system(f'docker run -t -i --rm \
    --name ostis\
    -v {KB_PATH}:{OSTIS_PATH}/kb \
    -v {PROBLEM_SOLVER_PATH}:{OSTIS_PATH}/problem-solver \
    -p {PORT_NEW}:8090 \
    -p {PORT_OLD}:8000 \
    {IMAGE}:{VERSION}')
