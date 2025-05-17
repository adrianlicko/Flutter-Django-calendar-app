## Start django server in terminal
```bash
# create and use python enviroment
pip install virtualenv
python -m venv venv
source venv/Scripts/activate

python manage.py makemigrations # create migration files for the database
python manage.py migrate # apply migrations

pip install -r requirements.txt # install required packages
python manage.py runserver # start server
```

## Start django server with docker
```bash
docker build -t django_app . # build image
docker run -p 8000:8000 django_app # start container from the image
```

### !!! If you want run flutter app on real device via adb, you need to start the server with this command:
```bash
python manage.py runserver 0.0.0.0:8000
adb reverse tcp:8000 tcp:8000 # tunnel for a mobile phone to be able to send and receive http requests
```


## See API swagger in browser
#### http://localhost:8000/swagger/