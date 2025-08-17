# urls.py
from django.urls import path
from .views import image_gallery

urlpatterns = [
    path('gallery/', image_gallery, name='gallery'),
]