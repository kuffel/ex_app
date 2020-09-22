FROM elixir:1.10.3

RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.14-1_all.deb \
&& apt-get update \
&& apt-get install -y lsb-release \
&& DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.14-1_all.deb

RUN apt-get update && apt-get install -y mysql-client wget openssl locales gnupg bash unzip curl

COPY . /opt/ex_app

ARG version

ENV REPLACE_OS_VARS true

ENV SECRET_KEY_BASE "FH/q1Nf8RE+GvA1ktjVCrPg8Gxe8HZVY8ykHjL0wZtw9UQXUYgBuikFqw4+EU2+d"

EXPOSE 4000
CMD ["/opt/ex_app/bin/ex_app", "start"]