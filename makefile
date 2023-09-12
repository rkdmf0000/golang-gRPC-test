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

#default: greets check-commands env-setup setup proto-clean proto build
default:
	@echo "all : 자동으로 설치 및 빌드까지 완료합니다"
	@echo "setup : 깃허브 설정을 완수합니다"
	@echo "check-commands : 필수적인 명령어가 설치되었는지 확인합니다"
	@echo "proto : proto 파일을 빌드합니다"
	@echo "build : main.go 파일을 빌드합니다"
	@echo "clean : 실행파일을 제거합니다"
	@echo "proto-clean : 빌드된 proto 파일을 제거합니다"
	@echo "push-to-git-origiin : 깃허브의 정의된 온라인 브런치에 모든 상태를 푸시합니다"
	@echo "env-setup : 해당 프로젝트에서 요구하는 빌드 환경을 다운로드 및 설치합니다"
	
	

all: greets check-commands env-setup setup proto-clean proto build

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

push-to-git-origiin: check-commands
	@echo "$(YELLOW)GitHub에 업로드 중...$(RESET)"
	@git add .
	@git commit -m " Immediately push on $(shell date)" > /dev/null || (echo "$(RED)깃허브 파일에 변동이 없습니다$(RESET)")
	@git push -u origin master
	@echo "$(YELLOW)실행 완료...$(RESET)"

env-setup: check-commands
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

.PHONY: all greets setup env-setup check-commands proto build clean proto-clean push-to-git-origiin
