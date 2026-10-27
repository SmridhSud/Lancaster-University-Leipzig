"""
It calculates if sequence of egg movement repeat itself.
"""
import sys

def solution():
    #token to read input 
    
    def token_get():
        for lines in sys.stdin:
            for words in lines.split():
                yield words
    
    token = token_get()
    
    try:
        #1 reading basic constraints
        n = int(next(token)) #number nests
        m = int(next(token)) #number morphers
        k = int(next(token)) #limit
        
        #2. reading egg counts
        egg_begin = []
        for _ in range(n):
            egg_begin.append(int(next(token)))
        state_begin = tuple(egg_begin)
       
       #3. reading morpher 
        morpher = []
        for _ in range(m):
            fd = int(next(token))
            ns = int(next(token))
            
            feeder = [int(next(token)) - 1 for _ in range(fd)]
            nurser = [int(next(token)) - 1 for _ in range(ns)]
            morpher.append((feeder, nurser))
            
    except(ValueError, StopIteration):
        return
    
    def repeating(current, path):
        """ 
        checks if current situation "repeating"
        """
        for previous in path:
            condition = True
            
            for i in range(n):
                if current[i] < previous[i]:
                    condition = False
                    break
            if condition:
                return True
        return False
    
    def loop_discover(state_current, paths, step):
        #recursive function 
        
        if repeating(state_current, paths):
            return True
        
        if step >= k:
            return False
        
        paths.append(state_current)
        
        for feeder, nurser in morpher:
            enable = True
            for f in feeder:
                if state_current[f] < 1:
                    enable = False
                    break
                
            if enable:
                state_next = list(state_current)
                for fe in feeder:
                    state_next[fe] -= 1
                for nr in nurser:
                    state_next[nr] += 1
                
                if loop_discover(tuple(state_next), paths, step + 1):
                    return True
        
        paths.pop()
        return False
    
    if loop_discover(state_begin, [], 0):
        print("Yes")
    else:
        print("No")

if __name__ == "__main__":
    solution()