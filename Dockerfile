FROM python:3.15.0b1-alpine3.23
MAINTAINER SanthoshNC
LABEL description="Infosectrain Demo"
RUN mkdir /app
COPY . /app
WORKDIR /app
EXPOSE 8080
CMD ["python3", "app.py"]
