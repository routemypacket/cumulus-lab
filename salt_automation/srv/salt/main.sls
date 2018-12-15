/etc/network/interfaces:
  file.managed:
    - source: salt://leaf/interfaces.jinja
    - template: jinja
    - {{ pillar[salt['grains.get']('id')] }}
