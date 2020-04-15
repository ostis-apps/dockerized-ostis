# Dockerized OSTIS

This is the official repository of the [Docker image](https://hub.docker.com/r/ostis/ostis) for [OSTIS](http://ims.ostis.net).

OSTIS (*Open Semantic Technology for Intelligent Systems*) is an open-source integrated mass technology for component-based intelligent systems design.

For application examples, visit the [OSTIS Applications](https://github.com/ostis-apps/) page.

## Docker Installation

Please find installation instructions for your operating system [here](https://docs.docker.com/install).

## Available image tags (versions)

To find an actual versions released as Docker images please see the [list of Docker hub tags](https://hub.docker.com/r/ostis/ostis/tags/).

Current versions:
* `scp_stable` - allows usage of agents on SCP. Please find more info [here](https://github.com/ostis-apps/ostis-example-app/tree/scp_stable)
* `0.5.0` - allows usage of agents on C++. Please find more info [here](https://github.com/ostis-apps/ostis-example-app/tree/0.5.0)
* `0.6.0` -  allows usage of [JSON-based Websocket protocol](http://ostis-dev.github.io/sc-machine/http/websocket/) to communicate with knowledge base and new interface version. Please find more info [here](https://github.com/ostis-apps/ostis-example-app/tree/0.6.0)

## Quickstart
You can run the OSTIS container like so:
* for `scp_stable` version:
    ```
    docker run -it -p 8000:8000 ostis/ostis:scp_stable
    ```
* for `0.5.0` version:
    ```
    docker run -it -p 8000:8000 ostis/ostis:0.5.0
    ```
* for `0.6.0` version:
    ```
    docker run -it -p 8000:8000 -p 8090:8090 ostis/ostis:0.6.0
    ```
Open `localhost:8000` in your browser to see web interface. For `0.6.0` version new interface version will be available on `localhost:8090`.

**Note**: you can specify custom port like so using `-p 8080:8000` as an example to run on `localhost:8080`.

## How to customize image

Custom knowledge base source folder and agents source folder can be set up using Docker volumes.

Add ``` -v full_path_to_kb_folder:/ostis/kb``` to specify your local folder with kb sources. 

Note that if you're using custom kb then kb folder should contain *ui_main_menu* and *ui_start_sc_element* like [here](https://github.com/ostis-apps/dockerized-ostis/tree/v0.5.0/kb). 
Be aware that by using custom kb you will not override existing ims.ostis.kb but add additional knowledge base sources.

Add ``` -v full_path_to_problem_solver_folder:/ostis/problem-solver``` to specify your local folder with problem-solver sources. 

Note that C++ agents should be inside **problem-solver/cxx** folder, SCP agents should be inside **problem-solver/scp** folder.

Example of usage:
```
docker run -it -v /home/user01/test/kb:/ostis/kb -v /home/user01/test/problem-solver:/ostis/problem-solver -p 8000:8000 -p 8090:8090 ostis/ostis:0.6.0
```


## Building image locally

To build image locally you will need:
1. Clone the repo:
    ```
    git clone https://github.com/ostis-apps/dockerized-ostis
    ```
2. Checkout to branch according to version you need
3. Run build image script:
    ```bash
    ./build_image.sh
    ```
## Run image locally using script

Run script has additional useful options comparing to Quickstart section. To run:
1. Clone the repo:
    ```
    git clone https://github.com/ostis-apps/dockerized-ostis
    ```
2. Checkout to branch according to version you need
3. Run the script with options (if needed):
    ```bash
    ./run.sh
    ```
Available options to use:
* `--help` or `-h` option to see all available options with description
* `--port` or `-p` option to set a custom port
* `--kb` option to set custom knowledge base source folder path
* `--solver` option to set custom problem solver source folder path
* `--app` option to set app folder path. Note that the app folder structure should be same as in the [ostis-example-app](https://github.com/ostis-apps/ostis-example-app/tree/0.5.0). It should contain kb and problem-solver folders inside

Example of usage:
```bash
./run.sh --app /home/user01/test/ostis-example-app
```

## Contribute

Pull requests are very welcome!

It would be great to hear your feedback and suggestions in the issue tracker: [github.com/ostis-apps/dockerized-ostis/issues](https://github.com/ostis-apps/dockerized-ostis/issues).
