x = int(input("ENTER THE LOOP LIMIT - "))
def f(x):
    for i in range(0,x):
        yield i
r = f(x)
for i in r:
        print(i)
        





