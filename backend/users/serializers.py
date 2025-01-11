from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()

class PreferencesSerializer(serializers.Serializer):
    locale = serializers.CharField(max_length=10, required=True)
    theme = serializers.CharField(max_length=50, required=True)
    showTodosInCalendar = serializers.BooleanField(required=True)
    removeTodoFromCalendarWhenCompleted = serializers.BooleanField(required=True)

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, allow_blank=True)
    preferences = PreferencesSerializer()

    class Meta:
        model = User
        fields = ['id', 'email', 'password', 'first_name', 'last_name', 'preferences']
        extra_kwargs = {
            'email': {'required': True},
            'first_name': {'required': True},
            'last_name': {'required': True},
        }

    def create(self, validated_data):
        preferences_data = validated_data.pop('preferences', {})
        password = validated_data.pop('password', None)
        email = validated_data.pop('email')

        user = User.objects.create_user(
            email=email,
            password=password,
            preferences=preferences_data,
            **validated_data
        )
        return user

    def validate_email(self, value):
        user = self.context['request'].user
        if User.objects.exclude(pk=user.pk).filter(email=value).exists():
            raise serializers.ValidationError("This email is already in use.")
        return value

    def update(self, instance, validated_data):
        preferences_data = validated_data.pop('preferences', None)
        password = validated_data.pop('password', None)

        # Update preferences if provided
        if preferences_data:
            instance.preferences = preferences_data

        # Update other fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        # Handle password update
        if password:
            instance.set_password(password)

        instance.save()
        return instance