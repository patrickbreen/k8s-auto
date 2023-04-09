FROM strm/dnsmasq:latest

COPY conf-dnsmasq/resolv.conf /etc/resolv.conf
COPY conf-dnsmasq/dnsmasq.conf /etc/dnsmasq.conf