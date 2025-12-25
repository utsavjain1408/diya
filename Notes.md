### Installing helm plugins
```

```

### Create go module
```
go mod init data-ingestion-service
```

### Run Mariadb
```
docker run -it --network diya-network --rm mariadb mariadb -h some-mariadb -u example-user

```
### Run data-ingestion-service
```
cd data-ingestion-service
go run .
```
