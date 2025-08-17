from django.shortcuts import render

# Create your views here.
# views.py
from django.shortcuts import render
from .models import Image

def image_gallery(request):
    # Fetch all image links from the database
    images = Image.objects.all()
    return render(request, 'domain/gallery.html', {'images': images})