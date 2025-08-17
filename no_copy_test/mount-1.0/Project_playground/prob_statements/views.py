from django.shortcuts import render

# Create your views here.
from .models import Frontend , Web_developement , Backend , AI_ML , Cybersecurity , Dev_ops , Data_science , Mobile_app_dev , Cloud_computing , Blockchain

def frontend_questions(request):
    f_questions = Frontend.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/frontend.html', {'f_questions': f_questions})
# views.py

def backend_questions(request):
    b_questions = Backend.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/backend.html', {'b_questions': b_questions})
# views.py

def web_questions(request):
    w_questions = Web_developement.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/web.html', {'w_questions': w_questions})
# views.py

def blockchain_questions(request):
    blc_questions = Blockchain.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/block.html', {'blc_questions': blc_questions})
# views.py

def mobile_questions(request):
    m_questions = Mobile_app_dev.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/Mobile.html', {'m_questions': m_questions})
# views.py

def datasci_questions(request):
    ds_questions = Data_science.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/datasci.html', {'ds_questions': ds_questions})
# views.py

def devops_questions(request):
    d_questions = Dev_ops.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/dev.html', {'d_questions': d_questions})
# views.py

def cyber_questions(request):
    cs_questions = Cybersecurity.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/cyber.html', {'cs_questions': cs_questions})
# views.py

def al_ml_questions(request):
    ai_questions = AI_ML.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/aiml.html', {'ai_questions': ai_questions})
# views.py

def cloud_questions(request):
    c_questions = Cloud_computing.objects.all()  # Fetch all questions from the database
    return render(request, 'prob_st/cloud.html', {'c_questions': c_questions})
# views.py