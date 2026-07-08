FROM python:3.12-slim

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

CMD ["python", "container_run.py"]
