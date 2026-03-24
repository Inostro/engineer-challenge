package interfaces

import (
	"context"

	"auth-service/internal/application"
	pb "auth-service/proto"
)

type GrpcServer struct {
	pb.UnimplementedAuthServiceServer
	commandHandler *application.CommandHandler
	queryHandler   *application.QueryHandler
}

func NewGrpcServer(cmd *application.CommandHandler, query *application.QueryHandler) *GrpcServer {
	return &GrpcServer{
		commandHandler: cmd,
		queryHandler:   query,
	}
}

func (s *GrpcServer) Register(ctx context.Context, req *pb.RegisterRequest) (*pb.AuthResponse, error) {
	token, err := s.commandHandler.Register(ctx, application.RegisterCommand{
		Email:    req.Email,
		Password: req.Password,
		Name:     req.Name,
	})
	if err != nil {
		return nil, err
	}

	return &pb.AuthResponse{Token: token}, nil
}

func (s *GrpcServer) Login(ctx context.Context, req *pb.LoginRequest) (*pb.AuthResponse, error) {
	token, err := s.commandHandler.Login(ctx, application.LoginCommand{
		Email:    req.Email,
		Password: req.Password,
	})
	if err != nil {
		return nil, err
	}

	return &pb.AuthResponse{Token: token}, nil
}

func (s *GrpcServer) RequestPasswordReset(ctx context.Context, req *pb.PasswordResetRequest) (*pb.Empty, error) {
	err := s.commandHandler.RequestPasswordReset(ctx, application.RequestPasswordResetCommand{
		Email: req.Email,
	})
	return &pb.Empty{}, err
}

func (s *GrpcServer) ResetPassword(ctx context.Context, req *pb.ResetPasswordRequest) (*pb.Empty, error) {
	err := s.commandHandler.ResetPassword(ctx, application.ResetPasswordCommand{
		Token:       req.Token,
		NewPassword: req.NewPassword,
	})
	return &pb.Empty{}, err
}
