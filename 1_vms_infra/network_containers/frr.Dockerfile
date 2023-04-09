FROM quay.io/frrouting/frr:master

COPY conf-frr/daemon.conf /etc/frr/daemon.conf
COPY conf-frr/frr.conf /etc/frr/frr.conf
COPY conf-frr/vtysh.conf /etc/frr/vtysh.conf