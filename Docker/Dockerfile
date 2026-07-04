# 1. Use an official lightweight Python runtime based on Alpine Linux
FROM python:3.12-alpine

# 2. Set the working directory inside the container container
WORKDIR /app

# 3. Install Flask dependency directly (keeps it simple without requirements.txt)
RUN pip install --no-cache-dir flask

# 4. Copy your local 'app' folder into the container's working directory
COPY ./app /app

# 5. Document that the container listens on port 5000 at runtime
EXPOSE 5000

# 6. The final command to run when the container wakes up
CMD ["python", "app.py"]