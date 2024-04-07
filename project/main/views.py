from django.shortcuts import render

# Create your views here.


def home(request):
    return render(request, 'main/home.html')


def showcase(request):
    return render(request, 'main/showcase.html')
