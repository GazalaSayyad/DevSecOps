# Use an official, lightweight Python base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Python script into the container
COPY main.py .

# Run the container as a non-root user for security
USER 10001

# Set the entrypoint to run the script
ENTRYPOINT ["python", "app.py"]
