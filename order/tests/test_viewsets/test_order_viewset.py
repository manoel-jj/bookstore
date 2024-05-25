import json

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient, APITestCase

from order.factories import OrderFactory, UserFactory
from order.models import Order
from product.factories import CategoryFactory, ProductFactory
from product.models import Product


class TestOrderViewSet(APITestCase):

    client = APIClient()

    def setUp(self):
        self.category = CategoryFactory(title="technology")
        self.product = ProductFactory(
            title="mouse", price=100, category=[self.category]
        )
        self.order = OrderFactory(product=[self.product])

    def test_order(self):
        response = self.client.get(reverse("order-list", kwargs={"version": "v1"}))
        order_data = json.loads(response.content)


        # Acessando o primeiro elemento da lista e o dicionário dentro dele
        order = order_data[0]

        # Acessando os dados do produto dentro do dicionário
        product = order["product"][0]

        # Realizando as comparações
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(product["title"], self.product.title)
        self.assertEqual(product["price"], self.product.price)
        self.assertEqual(product["active"], self.product.active)
        self.assertEqual(product["category"][0]["title"], self.category.title)

    def test_create_order(self):
        user = UserFactory()
        product = ProductFactory()
        data = json.dumps({"products_id": [product.id], "user": user.id})

        response = self.client.post(
            reverse("order-list", kwargs={"version": "v1"}),
            data=data,
            content_type="application/json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        created_order = Order.objects.get(user=user)