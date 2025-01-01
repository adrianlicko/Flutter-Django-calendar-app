from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'password', 'first_name', 'last_name', 'preferences']

    def create(self, validated_data):
        email = validated_data.pop('email')  # Odstránenie 'email' z validated_data
        password = validated_data.pop('password')
        username_base = email.split('@')[0]
        username = username_base
        counter = 1
        while User.objects.filter(username=username).exists():
            username = f"{username_base}{counter}"
            counter += 1
        user = User.objects.create(username=username, email=email, **validated_data)
        user.set_password(password)
        user.save()
        return user