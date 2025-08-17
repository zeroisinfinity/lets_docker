FROM alpine:latest

RUN apk add --no-cache nmap bash python3 py3-pip
RUN python3 -m venv /venv
RUN /venv/bin/pip install --upgrade pip
RUN /venv/bin/pip install --no-cache google-generativeai==0.8.5

COPY . /first

WORKDIR /first

CMD ["/venv/bin/python","gemini.py"]


