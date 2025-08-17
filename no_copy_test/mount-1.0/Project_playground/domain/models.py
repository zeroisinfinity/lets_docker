from django.db import models

# Create your models here.
# models.py

class Image(models.Model):
    title = models.CharField(max_length=100)  # Optional: Add a title for the image
    image_url = models.URLField()  # Store the image URL
    idd = models.IntegerField()
    def __str__(self):
        return self.title