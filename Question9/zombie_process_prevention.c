#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

int main() {
    int num_children = 5;
    pid_t pids[num_children];
    
    printf("Parent PID: %d - Creating %d children...\n", getpid(), num_children);
    
    // Create multiple child processes
    for (int i = 0; i < num_children; i++) {
        pid_t pid = fork();
        
        if (pid == 0) {
            // Child process
            printf("Child PID: %d (Parent: %d) - Working for %d seconds...\n", 
                   getpid(), getppid(), i + 1);
            sleep(i + 1);  // Simulate work with different durations
            printf("Child PID: %d terminating\n", getpid());
            exit(i + 1);   // Exit with unique status
        } else if (pid > 0) {
            // Parent: store child PID
            pids[i] = pid;
            printf("Parent: Created child PID %d\n", pid);
        } else {
            perror("fork failed");
            exit(1);
        }
    }
    
    // Parent waits for and cleans up ALL children to prevent zombies
    printf("\nParent waiting for children to terminate...\n");
    for (int i = 0; i < num_children; i++) {
        int status;
        pid_t child_pid = waitpid(pids[i], &status, 0);
        
        if (child_pid > 0) {
            printf("Parent cleaned up child PID %d (exit status: %d)\n", 
                   child_pid, WEXITSTATUS(status));
        }
    }
    
    printf("Parent: All children reaped - No zombies created!\n");
    return 0;
}