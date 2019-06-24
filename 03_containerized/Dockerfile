FROM python:3.7

RUN pip install jupyter
RUN mkdir /home/notebooks

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root", "/home/notebooks"]
