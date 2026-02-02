#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

volatile sig_atomic_t signal_received = 0;
pid_t sigterm_child = 0, sigint_child = 0;

// Signal handlers - use parent-known child PIDs
void sigterm_handler(int sig) {
    signal_received = SIGTERM;
    printf("\n[Parent PID %d] Caught SIGTERM from child PID %d\n", getpid(), sigterm_child);
}

void sigint_handler(int sig) {
    signal_received = SIGINT;
    printf("\n[Parent PID %d] Caught SIGINT from child PID %d\n", getpid(), sigint_child);
}

int main() {
    pid_t pid1, pid2;
    
    // Register signal handlers BEFORE forking
    struct sigaction sa_term = {0};
    sa_term.sa_handler = sigterm_handler;
    sigaction(SIGTERM, &sa_term, NULL);
    
    struct sigaction sa_int = {0};
    sa_int.sa_handler = sigint_handler;
    sigaction(SIGINT, &sa_int, NULL);
    
    printf("Parent PID %d starting - waiting indefinitely for signals...\n", getpid());
    
    // Child 1: SIGTERM sender (5 seconds)
    pid1 = fork();
    if (pid1 == 0) {
        sleep(5);
        printf("[Child PID %d] Sending SIGTERM to parent PID %d\n", getpid(), getppid());
        kill(getppid(), SIGTERM);
        exit(0);
    }
    
    sigterm_child = pid1;  // Parent tracks SIGTERM sender
    
    // Child 2: SIGINT sender (10 seconds)
    pid2 = fork();
    if (pid2 == 0) {
        sleep(10);
        printf("[Child PID %d] Sending SIGINT to parent PID %d\n", getpid(), getppid());
        kill(getppid(), SIGINT);
        exit(0);
    }
    
    sigint_child = pid2;  // Parent tracks SIGINT sender
    
    // Parent: wait indefinitely for signals
    while (1) {
        pause();
        
        if (signal_received == SIGTERM) {
            printf("[Parent] Handling SIGTERM - cleaning up SIGINT child %d\n", sigint_child);
            kill(sigint_child, SIGTERM);
            break;
        }
        else if (signal_received == SIGINT) {
            printf("[Parent] Handling SIGINT - cleaning up SIGTERM child %d\n", sigterm_child);
            kill(sigterm_child, SIGTERM);
            break;
        }
    }
    
    // Wait for both children
    int status;
    waitpid(pid1, &status, 0);
    waitpid(pid2, &status, 0);
    
    printf("[Parent PID %d] Exited gracefully after signal handling\n", getpid());
    return 0;
}
