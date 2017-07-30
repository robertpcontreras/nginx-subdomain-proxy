FROM alpine:3.6

RUN apk --update add --no-cache --update nginx supervisor; mkdir -p /run/nginx;

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./proxy.conf /etc/nginx/default.d/proxy.conf
ADD ./supervisor.ini /etc/supervisor/conf.d/nginx-supervisor.ini

EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/nginx-supervisor.ini"]