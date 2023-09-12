package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"

	userpb "gprcServer/proto"
)

const portNumber = "20000"

var UserData = []*userpb.UserMessage{
	{
		UserId:      "1",
		Name:        "Henry",
		PhoneNumber: "01012341234",
		Age:         22,
	},
	{
		UserId:      "2",
		Name:        "Michael",
		PhoneNumber: "01098128734",
		Age:         55,
	},
	{
		UserId:      "3",
		Name:        "Jessie",
		PhoneNumber: "01056785678",
		Age:         15,
	},
	{
		UserId:      "4",
		Name:        "Max",
		PhoneNumber: "01099999999",
		Age:         37,
	},
	{
		UserId:      "5",
		Name:        "Tony",
		PhoneNumber: "01012344321",
		Age:         25,
	},
}

type userServer struct {
	userpb.UserServer
}

// GetUser returns user message by user_id
func (s *userServer) GetUser(ctx context.Context, req *userpb.GetUserRequest) (*userpb.GetUserResponse, error) {
	userID := req.UserId

	var userMessage *userpb.UserMessage
	for _, u := range UserData {
		if u.UserId != userID {
			continue
		}
		userMessage = u
		break
	}

	return &userpb.GetUserResponse{
		UserMessage: userMessage,
	}, nil
}

// ListUsers returns all user messages
func (s *userServer) ListUsers(ctx context.Context, req *userpb.ListUsersRequest) (*userpb.ListUsersResponse, error) {
	userMessages := make([]*userpb.UserMessage, len(UserData))
	for i, u := range UserData {
		userMessages[i] = u
	}

	return &userpb.ListUsersResponse{
		UserMessages: userMessages,
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":"+portNumber)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()

	userpb.RegisterUserServer(grpcServer, &userServer{})

	log.Printf("start gRPC server on %s port", portNumber)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %s", err)
	}
}
