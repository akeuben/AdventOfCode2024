# Day 3
I decided (for some reason) to implement day 3 using a single tape turing machine. Here are some stats:

|  Part  | Number of States | Number of Transitions |
|--------|------------------|-----------------------|
| Part 1 | 1952             | 4901                  |
| Part 2 | 3011             | 5488                  |

Thankfully, I was able to resuse most of my part 1 implementation in part 2.

## The turing machine simulator
I wrote a simple c turing machine simulator to debug and execute the turing machine
for both parts. It simply stores all the transitions in a 1024x95 element instruction 
table which is read from the machine file. It is not the most space efficient, as non-existant
instructions still take up space, but the $O(1)$ access time allows both Part 1 and Part 2
to run in $<2s$ on my surface pro 7. 

## The Turing Machine
The turing machine is implemented as a few discrete steps:

### Step 1
The turing machine scans the tape for the pattern `mul(`. Once this is found,
it copies the next number to the end of the tape with a M prefix. Then the remaining 
digits are copied to the end up until the `,`. Then, a `B` followed by the remaining
digits up until the `)` are copied, and then a `R` is written to the end of the tape. 
Each digit and comma are replaced with the marker `S` to signify that the digit has been
read. If at any point the `mul` is interrupted by an unexpected character, a cleanup 
routine is run to remove all characters after (and including) the last `M` on the tape.

Once the machine encouters an `M`, we have reached the end of the original input, and can 
move on to step 3.

### Step 2
Once the `)` character is read on the tape, the machine performs the multiplication.
This is done through repeated addition. Each digit is stored in the machine state, from right
to left in the result. This part will be demonstrated by an example. The exact state numbers have been
simplified from the actual implementation to make it more clear to the reader:

If the tape currently reads `M3B20R20`, then first the machine will store the last digit
as state `q0`, and the tape reads `M3B21R2!`, where $!$ is used as a placeholder (to hold which 
digits have been marked, without losing its value. Then, each`possible combination of digits 
is manually coded into the machine to implement addition. Since $1+1=2$, the last character 
is replaced by `@`, and the next character is considered. The state gets changed to 
`q2`, and the tape reads `M3B21R@!`, ans since `2+2=4`, the tape will now read `M3B21R$!`.
Since we have now handled all digits (which we know as the next charater is `R`, we can 
decrement the $3$ to a $2$ and repeat the process (after replacing the placeholders with their true
values). We handle carrying through the state, both in the addition and decrement routines. 
Once the value after the `M` has reached 0, we can find the last `S` on the tape by repeatedly moving left,
and transitioning back to step 1.

### Step 3
Step 3 just involves adding all the results together, marked on the right by a $M$, which is implemented identically
to step 2. Once the tape head reads the end of the original input, the machine halts as all products have been summed.
The final value is displayed on the end of the tape.

## Compiling
A makefile is provided to compile the code automatically, which can be used with:
```
make
```

## Running
To use the turing machine, you can run the compiled code as follows:
```
./turing_machine [machine file] [tape file]
```
So for part 1, you would use:
```
./turing_machine part1 input
```

There is also a `run` script provided in the make file wich will
run bot hparts for you and display only the final result on each tape. This can
be used with:
```
make run
```
