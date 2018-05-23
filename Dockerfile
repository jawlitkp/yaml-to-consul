FROM python:3.6-alpine as BUILD
MAINTAINER Alexandru Ast <alexandru.ast@gmail.com>

ENV APP_HOME=/build
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN apk add -q --no-cache curl unzip \
&& curl -LSs https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip -o /tmp/consul_1.0.6_linux_amd64.zip \
&& unzip /tmp/consul_1.0.6_linux_amd64.zip -d /usr/local/bin \
&& (consul agent -dev >/dev/null &)

COPY . .

RUN pip install -r requirements.txt \
&& python tests/test_kvstore.py \
&& python kvstore.py

FROM python:3.6-alpine

COPY [ \
  "requirements.txt", \
  "kvstore.py", \
   "/" \
]

RUN pip install -r requirements.txt \
&& python kvstore.py --help

VOLUME [ "/config", "/import" ]

CMD ["python", "kvstore.py"]