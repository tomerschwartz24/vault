FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt


ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
CMD ["python3", "vault-validator.py"]