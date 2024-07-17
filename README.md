# Скрипты установки приложений для мониторинга и уведомлений

Набор скриптов для установки и базовой настройки различных приложений в системе Ubuntu

Для работы скрипта необходимы приложения `curl`, `wget`, `jq`, которые будут установлены при их отсутствии

В скрипты можно передать переменные окружения:

* `VERSION` - версия для установки. При отсутствии устанавливается последняя версия
* `OS` - тип операционной системы (`linux`, `darwin` и т.д, соответствует ОС в ссылках на скачивание). При отсутствии определяется автоматически
* `ARCH` - архитектура системы (`amd64`, `386`  и т.д, соответствует архитектуре в ссылках на скачивание). При отсутствии определяется автоматически

## prometheus.sh

Скрипт устанавливает или обновляет до последней версии [Prometheus](https://prometheus.io/) со страницы https://github.com/prometheus/prometheus/releases,
создает базовую конфигурацию, настраивает и запускает службу

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./prometheus.sh
```

Корректность установки можно проверить просмотром статуса сервиса `prometheus.service` и открытием веб интерфейса по адресу http://127.0.0.1:9090

```shell
systemctl status prometheus.service
```

## alertmanager.sh

Скрипт устанавливает или обновляет до последней версии [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) со страницы https://github.com/prometheus/alertmanager/releases, 
создает базовую конфигурацию, настраивает и запускает службу 

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./alertmanager.sh
```

Корректность установки можно проверить просмотром статуса сервиса `alertmanager.service` и открытием веб интерфейса по адресу http://127.0.0.1:9093 

```shell
systemctl status alertmanager.service
```

## node_exporter.sh

Скрипт устанавливает или обновляет до последней версии [Node exporter](https://github.com/prometheus/node_exporter) со страницы https://github.com/prometheus/node_exporter/releases,
создает базовую конфигурацию, настраивает и запускает службу

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./node_exporter.sh
```

Корректность установки можно проверить просмотром статуса сервиса `node_exporter.service` и открытием веб интерфейса по адресу http://127.0.0.1:9100

```shell
systemctl status node_exporter.service
```

## victoriametrics.sh

Скрипт устанавливает или обновляет до последней версии [VictoriaMetrics](https://victoriametrics.com/) со страницы https://github.com/VictoriaMetrics/VictoriaMetrics/releases,
создает базовую конфигурацию, настраивает и запускает службу

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./victoriametrics.sh
```

Корректность установки можно проверить просмотром статуса сервиса `victoriametrics.service` и открытием веб интерфейса по адресу http://127.0.0.1:8428

```shell
systemctl status victoriametrics.service
```

## vmagent.sh

Скрипт устанавливает или обновляет до последней версии [vmagent](https://docs.victoriametrics.com/vmagent.html) со страницы https://github.com/VictoriaMetrics/VictoriaMetrics/releases,
создает базовую конфигурацию, настраивает и запускает службу

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./vmagent.sh
```

Где:
* `VERSION` - версия для установки. При отсутствии устанавливается последняя версия
* `OS` - тип операционной системы (`linux`, `darwin` и т.д, соответствует ОС в ссылках на скачивание). При отсутствии определяется автоматически
* `ARCH` - архитектура системы (`amd64`, `386`  и т.д, соответствует архитектуре в ссылках на скачивание). При отсутствии определяется автоматически

Корректность установки можно проверить просмотром статуса сервиса `vmagent.service` и открытием веб интерфейса по адресу http://127.0.0.1:8429

```shell
systemctl status vmagent.service
```

## vmalert.sh

Скрипт устанавливает или обновляет до последней версии [vmalert](https://docs.victoriametrics.com/vmalert.html) со страницы https://github.com/VictoriaMetrics/VictoriaMetrics/releases,
создает базовую конфигурацию, настраивает и запускает службу

Команда запуска

```shell
[VERSION=<version>] [OS=<os>] [ARCH=<architecture>] ./vmalert.sh
```

Корректность установки можно проверить просмотром статуса сервиса `vmalert.service` и открытием веб интерфейса по адресу http://127.0.0.1:8880

```shell
systemctl status vmalert.service
```
