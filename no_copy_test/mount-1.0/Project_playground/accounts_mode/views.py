from django.shortcuts import render
from django.http import HttpResponse
# Create your views here.
def modes(req):
    return render(req , 'acc_mode/trymodes.html')
# views.py
def employer_page(request):
    return render(request, 'acc_mode/index.html')  # Render employer page template

def professional_page(request):
    return render(request, 'acc_mode/index.html')  # Render professional page template

def hobby_page(request):
    return render(request, 'acc_mode/index.html')  # Render hobby page template