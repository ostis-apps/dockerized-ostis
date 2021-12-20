$PORT_NEW = "8090"
$PORT_OLD = "8000"
$IMAGE = "ostis/ostis"
$VERSION = "0.6.0"

# Container paths
$OSTIS_PATH = "/ostis"

# Local paths
$APP_PATH = ${PWD}
$KB_PATH = "${APP_PATH}/kb"
$PROBLEM_SOLVER_PATH = "${APP_PATH}/problem-solver"

$SCRIPT_FLAGS = ""

function help
{
  write-output '
This is a tool for running container with OSTIS.

USAGE:
  .\run.ps1 [OPTIONS]

OPTIONS:
  --help -h         Print help message
  --port -p         Set a custom port for new client
  --port_old        Set a custom port for old client
  --app             Set a custom path to the app directory(By default, it is expected, that inside the app you have all default directories for kb, problem-solver etc)
  --kb              Set a custom path to kb directory
  --solver          Set a custom path to problem-solvers directory
  --startflags --sf To set container startup flags(using --all by default). Usage: --startflags "[OSTIS FLAGS]"

OSTIS FLAGS:
  --help -h             Print help message
  --all -a              Run all services
  --sc-mashine --scm    Rebuild sc-machine
  --build_kb --kb       Rebuild kb
  --sc-web --web        Run sc-web only
  --sctp                Run sctp only
'
}


for ( $i = 0; $i -lt $args.count; $i++ )
{
    switch ( $args[$i] )
    {
        {$_ -in "--help", "-h"}
        {
            help
            exit 0
        }

        {$_ -in "--port", "-p"}
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty port value!"
                help
                exit 1
            }
            else { $PORT_NEW = $args[$($i + 1)] }
        }

        "--port_old"
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty port value!"
                help
                exit 1
            }
            else { $PORT_OLD = $args[$($i + 1)] }
        }

        "--app"
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty app path value!"
                help
                exit 1
            }
            else
            {
                $APP_PATH = $args[$($i + 1)]
                $KB_PATH = "${APP_PATH}/kb"
                $PROBLEM_SOLVER_PATH = "${APP_PATH}/problem-solver"
            }
        }

        "--kb"
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty kb path value!"
                help
                exit 1
            }
            else { $KB_PATH = $args[$($i + 1)] }
        }

        "--solver"
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty problem-solver path value!"
                help
                exit 1
            }
            else { $PROBLEM_SOLVER_PATH = $args[$($i + 1)] }
        }

        {$_ -in "--startflags", "--sf"}
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "Cannot handle empty startup flags!"
                help
                exit 1
            }
            else { $SCRIPT_FLAGS = $args[$($i + 1)] }
        }

        {$_ -in "--compile", "-c"}
        {
            if ( $null -eq $args[$($i + 1)] )
            {
                write-output "No argument given!"
                help
                exit 1
            }
            else { $SCRIPT_FLAGS = $args[$($i + 1)] }
        }
    }
}

if (${SCRIPT_FLAGS} -eq $null)
{
  $SCRIPT_FLAGS = "--all"
}

docker run -t -i `
  -v ${KB_PATH}:${OSTIS_PATH}/kb `
  -v ${PROBLEM_SOLVER_PATH}:${OSTIS_PATH}/problem-solver `
  -p ${PORT_NEW}:8090 `
  -p ${PORT_OLD}:8000 `
  ${IMAGE}:${VERSION} `
  ${SCRIPT_FLAGS}

exit