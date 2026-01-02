from pathlib import Path
p=Path(r"c:\Users\HP\Desktop\MercaNica\merca_nica\lib\features\seller\seller_create_product_screen.dart")
s=p.read_text()
stack=[]
pairs={'(':')','[':']','{':'}'}
openers='([{'
closers=')]}'
for idx,ch in enumerate(s,1):
    if ch in openers:
        stack.append((ch,idx))
    elif ch in closers:
        if not stack:
            print('Unmatched closer',ch,'at pos',idx)
            break
        last,pos=stack.pop()
        if pairs[last]!=ch:
            print('Mismatched',last,'at',pos,'with',ch,'at',idx)
            break
else:
    if stack:
        last,pos=stack[-1]
        print('Unclosed opener',last,'at pos',pos)
    else:
        print('All matched')
# Additionally print line/column for last unclosed if any
if stack:
    stext=s[:stack[-1][1]-1]
    line=stext.count('\n')+1
    col=stack[-1][1]-stext.rfind('\n')-1
    print(f'Last unclosed at line {line}, column {col}')
