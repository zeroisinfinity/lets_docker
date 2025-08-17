from django.contrib import admin
from django.urls import path
from .views import modes
from .views import employer_page, professional_page, hobby_page  # Import your views

urlpatterns = [
    path('',modes),
    path('employer/', employer_page, name='employer'),  # Employer page
    path('professional/', professional_page, name='professional'),  # Professional page
    path('hobby/', hobby_page, name='hobby'),  # Hobby page
]