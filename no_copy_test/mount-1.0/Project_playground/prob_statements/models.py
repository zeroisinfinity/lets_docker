from django.db import models

# Create your models here.
# models.py

class Frontend(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Backend(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class AI_ML(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Blockchain(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Data_science(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Web_developement(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Mobile_app_dev(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Cybersecurity(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question


class Cloud_computing(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question

class Dev_ops(models.Model):
    question = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    difficulty = models.CharField(max_length=50, choices=[('Easy', 'Easy'), ('Medium', 'Medium'), ('Hard', 'Hard')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.question