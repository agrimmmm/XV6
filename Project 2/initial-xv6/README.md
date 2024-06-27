# xv6 Copy on Write

## Modified Priority Based Scheduler in xv-6 (PBS)

This part of the project involves the implementation of preemptive priority based scheduling. The priority is based on the following factors:
 1. The `Dynamic Priority (DP)` which is defined by the following formula:  
                    `DP = min(SP + RBI, 100)`  
    where
       - `SP` stands for `Static Priority` and is assigned by the user. The default value is *50*.
       - `RBI` stands for `Recent Behaviour Index` (default value = *25*) and is calculated by the following formula:  
                    `RBI = max(Int((3 * RTime - STime -WTime)*50/(RTime + WTime + STime + 1)), 0)`
    where
       - `RTime`: The total time the process has been running since it was last scheduled.
       - `WTime`: The total time the process has spent in the ready queue waiting to be scheduled.
       - `STime`: The total time the process has spent sleeping (i.e., blocked and not using CPU time) since it was last scheduled.
 2. If more than 1 process have the same `DP`, then the tie is broken by `the number of times the process has been scheduled` in ascending order.
 3. If it still results in a tie, the processes are scheduled on the basis of `the creation time` of the process in descending order.

### Set priority system call
This system call to change the `Static Priority(SP)` of a process.  
It returns the old static_priority and assigns new priority to the process. The pid of the process and the new priority is taken in as command line arguments. If the new priority is higher (larger in value) than the old priority then `yield()` is called and control of the system is handed over.

### Analysis
The method schedules the processes on the basis of priority assigned to each process and is a good scheduling technique where processes need to be schedule on the basis of their importance.  
Average rtime 16,  wtime 167 for PBS  
Average rtime 18,  wtime 171 for RR  

## COW Copy on Write Fork in xv-6

This implementation saves the memory when multiple processes are forked and each of them gets new pages exactly copied from the parent.   
COW shares the pages until some process wants to write. Now that particular page which is to be modified is copied for the process and hence saves memory by avoiding unnecessary copies.

### Implementation
Where the copy is made for the pages, we introduce a new flag PTE_COW and set it to 1 and make shared pages unwritable by modifying the PTE_W flag
Whenever interrupt happens for writing to the shared page we allocate a new copy to the process by cow_alloc and copy the contents of the shared page to it and it can then modify the page.  
Changes were made to the `copyout` function also to check for `pagefaults` while switching from kernel to user mode.  
To free a page, we maintain a count, it is incremented when it is shared and decremented when the process sharing it exits until its value is 0, upon which the page is freed.  
  
xv6 kernel is booting  
  
$ cowtest  
simple: ok  
simple: ok  
three: ok  
three: ok  
three: ok  
file: ok  
ALL COW TESTS PASSED  
