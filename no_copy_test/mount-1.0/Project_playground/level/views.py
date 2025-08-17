from django.shortcuts import render

# Create your views here.
# views.py
from django.shortcuts import render



def difficulty1(request):
    return render(request, 'lev/f.html')
def difficulty2(request):
    return render(request, 'lev/ai.html')
def difficulty3(request):
    return render(request, 'lev/b.html')
def difficulty4(request):
    return render(request, 'lev/ds.html')
def difficulty5(request):
    return render(request, 'lev/w.html')
def difficulty6(request):
    return render(request, 'lev/m.html')
def difficulty7(request):
    return render(request, 'lev/cs.html')
def difficulty8(request):
    return render(request, 'lev/c.html')
def difficulty9(request):
    return render(request, 'lev/dev.html')
def difficulty10(request):
    return render(request, 'lev/blc.html')