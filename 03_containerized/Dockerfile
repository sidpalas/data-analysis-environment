FROM python:3.7

COPY ./requirements.txt /tmp
WORKDIR /tmp
RUN pip install -r requirements.txt
RUN mkdir /home/notebooks

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root", "/home/notebooks"]
