package main

import (
	"fmt"
	"log"
	"net"

	"auth-service/internal/application"
	"auth-service/internal/infrastructure"
	"auth-service/internal/interfaces"
	pb "auth-service/proto"

	"google.golang.org/grpc"
)

func main() {
	repo := infrastructure.NewMemoryRepo()
	hasher := &infrastructure.PasswordHasher{}
	jwtService := infrastructure.NewJWTService("your-secret-key-change-me")
	emailService := &infrastructure.EmailMock{}

	commandHandler := &application.CommandHandler{
		Repo:   repo,
		Hasher: hasher,
		JWT:    jwtService,
		Mail:   emailService,
	}

	queryHandler := &application.QueryHandler{
		Repo: repo,
	}

	grpcServer := interfaces.NewGrpcServer(commandHandler, queryHandler)

	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterAuthServiceServer(s, grpcServer)

	fmt.Println("Server running on :50051")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
