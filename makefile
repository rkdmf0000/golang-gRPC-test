# Makefile

# ANSI escape codes for colors
RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
BLUE = \033[34m
MAGENTA = \033[35m
CYAN = \033[36m
RESET = \033[0m

PROTO_FILES = $(wildcard proto/*.proto)
GENERATED_GO = $(wildcard proto/*.pb.go)

GITEMAIL = "rkdmf0000@gmail.com"
GITUSER = "taxi_tabby"

GOPATH = "/root/go/"

all: greets check-commands setup proto-clean proto build

greets:
	@echo "*──────────────────────────────────────────*"
	@echo "*──────────────────────────────────────────*"
	@echo "*──────────────────────────────────────────*"
	@echo "$(CYAN)빌드 실행 시간 : $(shell date) $(RESET)"
	@echo "$(CYAN)GOROOT : $(GOPATH) $(RESET)"
	
	@echo "*──────────────────────────────────────────*"
	@echo "*──────────────────────────────────────────*"
	@echo "*──────────────────────────────────────────*"

setup: check-commands
	@echo "$(YELLOW)Git 설정 중...$(RESET)"
	@git config --global user.email "$(GITEMAIL)"
	@git config --global user.name "$(GITUSER)"
	@echo "$(YELLOW)Git 설정 완료 (user.email, user.name 을 사전에 정의된 대로 global 로 설정합니다)$(RESET)"
	@echo "- user.email $(GITEMAIL)"
	@echo "- user.name $(GITUSER)"

check-commands:
	@echo "$(CYAN)git이 사용 가능한지 확인 중...$(RESET)"
	@git --version > /dev/null || (echo "$(RED)오류: git이 사용 가능하지 않습니다. 설치해주세요.$(RESET)" && exit 1)
	@echo "$(CYAN)protoc가 사용 가능한지 확인 중...$(RESET)"
	@protoc --version > /dev/null || (echo "$(RED)오류: protoc가 사용 가능하지 않습니다. 설치해주세요.$(RESET)" && exit 1)
	@echo "$(CYAN)go가 사용 가능한지 확인 중...$(RESET)"
	@go version > /dev/null || (echo "$(RED)오류: go가 사용 가능하지 않습니다. 설치해주세요.$(RESET)" && exit 1)

proto: proto-clean check-commands $(PROTO_FILES)
	@echo "$(MAGENTA).proto 파일 컴파일 시작...$(RESET)"
	@for file in $(PROTO_FILES); do \
		echo "$(MAGENTA)$$file 컴파일 중...$(RESET)"; \
		protoc --proto_path=./proto $$file \
		--grpc-gateway_out ./proto \
		--grpc-gateway_opt logtostderr=true \
		--grpc-gateway_opt paths=source_relative \
		--plugin="$(GOPATH)/bin/protoc-gen-go-grpc" \
		--go-grpc_out=paths=source_relative:./proto \
		--plugin="$(GOPATH)/bin/protoc-gen-go" \
		--go_out=paths=source_relative:./proto;\
	done

build: proto-clean check-commands
	@echo "$(BLUE)main.go 빌드 중...$(RESET)"
	@go build -o result main.go

clean:
	@echo "$(GREEN)정리 중...$(RESET)"
	@rm -f result

proto-clean:
	@echo "$(GREEN)proto/ 내 생성된 .go 파일 정리 중...$(RESET)"
	@rm -f $(GENERATED_GO)

deploy-to-git: check-commands
	@echo "$(YELLOW)GitHub에 업로드 중...$(RESET)"
	@git add .
	@git commit -m " Immediately deployed on $(shell date)" > /dev/null || (echo "$(RED)깃허브 파일에 변동이 없습니다$(RESET)")
	@git push -u origin master
	@echo "$(YELLOW)실행 완료...$(RESET)"

setup: check-commands
	@echo "$(YELLOW)환경 초기 설정 실행...$(RESET)"
	@go get -d -u github.com/golang/protobuf/protoc-gen-go
	@go get -d -u github.com/golang/protobuf/proto
	@go get -u google.golang.org/grpc
	@go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	@go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
	@export PATH="$PATH:$(go env GOPATH)/bin"
	@go mod tidy
	@echo "$(YELLOW)실행 완료...$(RESET)"

.PHONY: all setup proto build clean proto-clean check-commands deploy-to-git setup
