FROM conda/miniconda3

WORKDIR /app

COPY requirements.txt .
# install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# additional openCV dependencies
RUN apt-get update && apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev
COPY . /app
# get keras weights
RUN [ "python", "./setup.py" ]

CMD ["gunicorn", "--bind=0.0.0.0:5000", "--workers=5", "--timeout=60", "app:get_app()"]
