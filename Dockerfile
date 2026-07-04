FROM python:3.12-slim-bookworm

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements/base.txt requirements/dev.txt requirements/
RUN pip install --no-cache-dir -r requirements/dev.txt

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=", "--NotebookApp.password="]
