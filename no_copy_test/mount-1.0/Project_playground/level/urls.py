# urls.py
from django.urls import path
from .views import difficulty1

urlpatterns = [
    path('difficulty/', difficulty1, name='difficulty'),
]