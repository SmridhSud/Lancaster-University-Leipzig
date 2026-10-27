"""
Goal: checks whether every room can be heated at most k pipes

input:
n m k
m lines follow each pipe:
t_i c_i1, c_i2...

output:
Print "Yes" every room would be heated, or else "No"

Approach:
check all combinaltions of pipes upto  size k--as small number of pipes-- and see if combination covers every room
"""

from itertools import combinations

#reads number rooms, pipe and  max pipes allowed
n, m, k = map(int, input().split())

pipes = []
for _ in range(m):
    data = list(map(int, input().split()))
    t = data[0]
    rooms = set(data[1:])
    pipes.append(rooms)
    
#sets of every room connected to each pipe
every_room = set(range(1, k + 1))

#determine all pipe combination upto size k
for r in range(1, k + 1):
    for com in combinations(pipes, r):
        
        heat = set()
        
        #combine heated rooms
        for piped in com:
            heat |= piped
            
        if heat == every_room:
            print("Yes")
            exit()
            
print("No")