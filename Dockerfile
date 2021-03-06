FROM ubuntu:14.04
MAINTAINER Medici.Yan@Gmail.com
ENV LC_ALL C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# apt and pip mirrors

# RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
#     && mkdir -p ~/.pip \
#     && echo "[global]" > ~/.pip/pip.conf \
#     && echo "timeout=60" >> ~/.pip/pip.conf \
#     && echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf

# install requirements

RUN set -x \
    && apt-get update \
    && apt-get install -y wget unzip gcc libssl-dev libffi-dev python-dev libpcap-dev python-pip

# upgrade pip
RUN python -m pip install --upgrade pip

RUN python -V ; pip -V

# install mongodb

ENV MONGODB_TGZ https://sec.ly.com/mirror/mongodb-linux-x86_64-3.4.0.tgz
RUN set -x \
    && wget -O /tmp/mongodb.tgz $MONGODB_TGZ \
    && mkdir -p /opt/mongodb \
    && tar zxf /tmp/mongodb.tgz -C /opt/mongodb --strip-components=1 \
    && rm -rf /tmp/mongodb.tgz

ENV PATH /opt/mongodb/bin:$PATH

# install xunfeng
RUN mkdir -p /opt/xunfeng
COPY . /opt/xunfeng

# setuptools 45 no longer support python2.7
RUN set -x \
    && pip install --upgrade 'setuptools<45.0.0'

# Six issue when installing package: https://github.com/pypa/pip/issues/3165#issuecomment-146666737
RUN pip install --ignore-installed "six>=1.6.0"

RUN set -x \
    && pip install -r /opt/xunfeng/requirements.txt \
    && ln -s /usr/lib/x86_64-linux-gnu/libpcap.so /usr/lib/x86_64-linux-gnu/libpcap.so.1

RUN set -x \
    && chmod a+x /opt/xunfeng/masscan/linux_64/masscan \
    && chmod a+x /opt/xunfeng/dockerconf/start.sh

WORKDIR /opt/xunfeng

VOLUME ["/data"]

ENTRYPOINT ["/opt/xunfeng/dockerconf/start.sh"]

EXPOSE 80
EXPOSE 65521

#保持容器不退出
CMD ["/usr/bin/tail", "-f", "/dev/null"]
