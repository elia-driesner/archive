from django.urls import path
from . import views

urlpatterns = [
    path('generate', views.generateToken, name="generate token")
]