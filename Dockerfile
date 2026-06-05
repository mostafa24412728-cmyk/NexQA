# Use Python 3.10 slim base
FROM python:3.10-slim

# Install system dependencies for OpenCV and YOLOv8
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (layer caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all project files
COPY . .

# Create uploads directory
RUN mkdir -p static/uploads

# Hugging Face Spaces uses port 7860
EXPOSE 7860

# Use gunicorn for production — HF Spaces provides PORT=7860
CMD gunicorn --bind 0.0.0.0:7860 --workers 1 --timeout 120 app:app
