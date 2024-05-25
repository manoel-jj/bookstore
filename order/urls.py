from django.urls import path, include
from rest_framework.routers import SimpleRouter
from order import viewsets

router = SimpleRouter()
router.register(r'order', viewsets.OrderViewSet, basename='order')

urlpatterns = [
    path('', include(router.urls)),
]
