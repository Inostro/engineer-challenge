package application

import (
	"auth-service/internal/domain"
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
)

type CommandHandler struct {
	Repo   UserRepository
	Hasher PasswordHasher
	JWT    JWTService
	Mail   EmailService
}

type UserRepository interface {
	Create(ctx context.Context, user *domain.User) error
	FindByEmail(ctx context.Context, email string) (*domain.User, error)
	FindByID(ctx context.Context, id string) (*domain.User, error)
	Update(ctx context.Context, user *domain.User) error
	SaveResetToken(ctx context.Context, token *domain.ResetToken) error
	FindResetToken(ctx context.Context, token string) (*domain.ResetToken, error)
	MarkResetTokenUsed(ctx context.Context, token string) error
}

type PasswordHasher interface {
	Hash(password string) (string, error)
	Compare(hashed, plain string) error
}

type JWTService interface {
	Generate(userID string) (string, error)
	Validate(token string) (string, error)
}

type EmailService interface {
	SendResetPassword(email, token string) error
}

type RegisterCommand struct {
	Email    string
	Password string
	Name     string
}

func (h *CommandHandler) Register(ctx context.Context, cmd RegisterCommand) (string, error) {
	if err := domain.ValidateEmail(cmd.Email); err != nil {
		return "", err
	}
	if err := domain.ValidatePassword(cmd.Password); err != nil {
		return "", err
	}

	existing, _ := h.Repo.FindByEmail(ctx, cmd.Email)
	if existing != nil {
		return "", errors.New("user already exists")
	}

	hashedPassword, err := h.Hasher.Hash(cmd.Password)
	if err != nil {
		return "", err
	}

	user := &domain.User{
		ID:        uuid.New().String(),
		Email:     cmd.Email,
		Password:  hashedPassword,
		Name:      cmd.Name,
		Active:    true,
		CreatedAt: time.Now(),
	}

	if err := h.Repo.Create(ctx, user); err != nil {
		return "", err
	}

	// генерируем JWT
	token, err := h.JWT.Generate(user.ID)
	if err != nil {
		return "", err
	}

	return token, nil
}

type LoginCommand struct {
	Email    string
	Password string
}

func (h *CommandHandler) Login(ctx context.Context, cmd LoginCommand) (string, error) {
	user, err := h.Repo.FindByEmail(ctx, cmd.Email)
	if err != nil {
		return "", errors.New("invalid credentials")
	}

	if err := user.CanLogin(); err != nil {
		return "", err
	}

	if err := h.Hasher.Compare(user.Password, cmd.Password); err != nil {
		return "", errors.New("invalid credentials")
	}

	return h.JWT.Generate(user.ID)
}

type RequestPasswordResetCommand struct {
	Email string
}

func (h *CommandHandler) RequestPasswordReset(ctx context.Context, cmd RequestPasswordResetCommand) error {
	user, err := h.Repo.FindByEmail(ctx, cmd.Email)
	if err != nil {
		return nil
	}

	token := uuid.New().String()
	resetToken := &domain.ResetToken{
		Token:     token,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(15 * time.Minute),
		Used:      false,
	}

	if err := h.Repo.SaveResetToken(ctx, resetToken); err != nil {
		return err
	}

	return h.Mail.SendResetPassword(user.Email, token)
}

type ResetPasswordCommand struct {
	Token       string
	NewPassword string
}

func (h *CommandHandler) ResetPassword(ctx context.Context, cmd ResetPasswordCommand) error {
	if err := domain.ValidatePassword(cmd.NewPassword); err != nil {
		return err
	}

	resetToken, err := h.Repo.FindResetToken(ctx, cmd.Token)
	if err != nil {
		return errors.New("invalid token")
	}

	if resetToken.Used {
		return errors.New("token already used")
	}

	if time.Now().After(resetToken.ExpiresAt) {
		return errors.New("token expired")
	}

	user, err := h.Repo.FindByID(ctx, resetToken.UserID)
	if err != nil {
		return errors.New("user not found")
	}

	hashedPassword, err := h.Hasher.Hash(cmd.NewPassword)
	if err != nil {
		return err
	}

	user.Password = hashedPassword
	if err := h.Repo.Update(ctx, user); err != nil {
		return err
	}

	if err := h.Repo.MarkResetTokenUsed(ctx, cmd.Token); err != nil {
		return err
	}

	return nil
}
