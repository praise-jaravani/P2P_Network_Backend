FROM python:3.10-slim

WORKDIR /app

# Copy requirements first to leverage Docker caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . .

# Make the start script executable
RUN chmod +x start.sh

# Create required directories
RUN mkdir -p files seeder_files logs

# Expose the backend port
EXPOSE 8000

# Set the entrypoint to the start script
CMD ["./start.sh"]