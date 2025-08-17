from . import views
from django.urls import path

urlpatterns = [
    path('frontend-questions/', views.frontend_questions, name='frontend_questions'),
]