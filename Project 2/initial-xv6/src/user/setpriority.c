#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
    if(argc != 3)
    {
        printf("Usage: setpriority pid priority");
        return 0;
    }

    int pid = atoi(argv[1]);
    int priority = atoi(argv[2]);

    setpriority(pid, priority);
    return 0;
}