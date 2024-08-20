#include "llm_server_dart.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

pid_t pid = -1;

extern int main(int argc, char* argv[]);

int quit() {
    if (pid == -1)
        return 1;
    kill(pid, SIGINT);
    pid = -1;

    return 0;
}

int start(int argc, char *argv[]) {
    if (pid != -1)
        return 1;

    pid = fork();

    if (pid == -1) {
        return 1;
    } else if (pid == 0) {
        main(argc, argv);
        return 0;
    } else {
        return 0;
    }
}
