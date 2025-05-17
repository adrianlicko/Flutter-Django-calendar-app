from django.db import models
from users.models import User

class Schedule(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    room = models.CharField(max_length=255, null=True, blank=True)
    week_day = models.IntegerField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    color = models.CharField(max_length=7)