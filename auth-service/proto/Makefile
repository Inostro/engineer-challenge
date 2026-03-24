.PHONY: proto
proto:
	protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		auth.proto

.PHONY: run
run:
	go run cmd/main.go

.PHONY: test
test:
	go test -v ./...

.PHONY: docker-build
docker-build:
	docker build -t auth-service .

.PHONY: docker-up
docker-up:
	docker-compose -f deployments/docker-compose.yml up