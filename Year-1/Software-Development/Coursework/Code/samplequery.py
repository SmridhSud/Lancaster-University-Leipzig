""" 
The system parses n samples, each consisting m properties
Recursively constructs a logic tree based on leading space indentation
Assess boolean expressions, incorporating AND, OR, NOT, and comparison operations
"""

import sys

def solution():
    def lines_get():
        return sys.stdin.readline()
    
    #parse dimension (n = sample, m = properties, k= query lines)
    line_first = lines_get().strip()
    if not line_first: return
    
    head  = line_first.split()
    if len(head) == 1 and len(head[0]) >= 3:
        h  = head[0]
        n, m, k = int(h[0]), int(h[1]), int(h[2:])
    else:
        n, m, k = map(int, head)
        
    names_prop = [p.strip() for p in lines_get().split(',')]
    types_prop = [t.strip() for t in lines_get().split(',')]
    
    #parse sample (n lines)
    sample=[]
    for _ in range(n):
        row = [value.strip() for value in lines_get().split(',')]
        dict_samples = {}
        for i in range(m):
            names, t, value = names_prop[i], types_prop[i], row[i]
            #convert natives types for accurate mathematical comparison
            if 'int' in t: dict_samples[names] = int(value)
            elif 'float' in t: dict_samples[names] = float(value)
            else: dict_samples[names] = value
        sample.append(dict_samples)
    
    #parse query  tree (k lines)
    lines_query = [lines_get() for _ in range(k)]
    
    def indents_get(s):
        return len(s) - len(s.lstrip())
    
    def tree_build(id):
        lines = lines_query[id]
        indents = indents_get(lines)
        contents = lines.strip()
        
        children = []
        current = id + 1
        while current < k:
            children_indent= indents_get(lines_query[current])
            
            if children_indent > indents:
                node_children, id_next = tree_build(current)
                children.append(node_children)
                current = id_next
            else:
                break
        return{'cmd':contents, 'children': children}, current
    
    if not lines_query: return
    query_root, _ = tree_build(0)
    
    #assess engine
    def assess(node, samples):
        token = node['cmd'].split()
        operation = token[0].upper()
        
        if operation == 'AND':          
            return all(assess(c, samples) for c in node['children'])
        if operation == 'OR':
            return any(assess(c, samples) for c in node['children'])
        if operation == 'NOT':
            return not assess (node['children'][0], samples)
        
        cmd = node['cmd']
        if '”' in cmd:
            target = cmd.split('”')[1]
        elif '"' in cmd:
            target = cmd.split('"')[1]
        else:
            target = token[-1]
        
        property = token[1]
        value = samples[property]
        
        if operation in ('LESSTHAN', 'FLESSTHAN'): return value < float(target)
        if operation in ('GREATERTHAN', 'FGREATERTHAN'): return value > float(target)
        if operation == 'EQUALS': return str(value) == target
        if operation == 'CONTAINS': return target in str(value)
        if operation == 'STARTSWITH': return str(value).startswith(target)
        if operation == 'ENDSWITH': return str(value).endswith(target)
        return False
    
    print(sum(1 for s in sample if assess(query_root, s)))
    
if __name__ == "__main__":
    solution()