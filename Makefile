.PHONY: run fmt test vet

run:
	go run ./cmd/server

fmt:
	gofmt -w cmd internal

test:
	go test -race ./...

vet:
	go vet ./...
