# Makefile

# ANSI escape codes for colors
RED = \033[31m
GREEN = \033[32m
RESET = \033[0m

PROTO_FILES = $(wildcard proto/*.proto)
GENERATED_GO = $(wildcard proto/*.pb.go)

all: check-commands proto-clean proto build

check-commands:
	@echo "$(GREEN)protoc가 사용 가능한지 확인 중...$(RESET)"
	@protoc --version > /dev/null || (echo "$(RED)오류: protoc가 사용 가능하지 않습니다. 설치해주세요.$(RESET)" && exit 1)
	@echo "$(GREEN)go가 사용 가능한지 확인 중...$(RESET)"
	@go version > /dev/null || (echo "$(RED)오류: go가 사용 가능하지 않습니다. 설치해주세요.$(RESET)" && exit 1)

proto: proto-clean $(PROTO_FILES)
	@echo "$(GREEN).proto 파일 컴파일 중...$(RESET)"
	@for file in $(PROTO_FILES); do \
		echo "$(GREEN)$$file 컴파일 중...$(RESET)"; \
		protoc --go_out=paths=source_relative:. $$file; \
	done

build: proto-clean
	@echo "$(GREEN)고랭고랭 플젝 빌드 중...$(RESET)"
	@go build -o result main.go

clean:
	@echo "$(GREEN)정리 중...$(RESET)"
	@rm -f result

proto-clean:
	@echo "$(GREEN)proto/ 내 생성된 .go 파일 정리 중...$(RESET)"
	@rm -f $(GENERATED_GO)

.PHONY: all proto build clean proto-clean check-commands
