package test

// go test -v ./test/
import (
	"context"
	"testing"

	"auth-service/internal/application"
	"auth-service/internal/domain"
	"auth-service/internal/infrastructure"
)

func TestRegisterAndLogin(t *testing.T) {
	repo := infrastructure.NewMemoryRepo()
	hasher := &infrastructure.PasswordHasher{}
	jwtService := infrastructure.NewJWTService("test-secret-key")
	emailService := &infrastructure.EmailMock{}

	cmdHandler := &application.CommandHandler{
		Repo:   repo,
		Hasher: hasher,
		JWT:    jwtService,
		Mail:   emailService,
	}

	queryHandler := &application.QueryHandler{
		Repo: repo,
	}

	ctx := context.Background()

	t.Run("register new user", func(t *testing.T) {
		cmd := application.RegisterCommand{
			Email:    "test@example.com",
			Password: "password123",
			Name:     "Test User",
		}

		token, err := cmdHandler.Register(ctx, cmd)
		if err != nil {
			t.Errorf("Register failed: %v", err)
		}
		if token == "" {
			t.Error("Token should not be empty")
		}

		user, err := queryHandler.GetUserByEmail(ctx, "test@example.com")
		if err != nil {
			t.Errorf("User not found: %v", err)
		}
		if user.Email != "test@example.com" {
			t.Errorf("Expected email test@example.com, got %s", user.Email)
		}
		if user.Name != "Test User" {
			t.Errorf("Expected name Test User, got %s", user.Name)
		}
	})

	t.Run("register duplicate email", func(t *testing.T) {
		cmd := application.RegisterCommand{
			Email:    "test@example.com",
			Password: "password123",
			Name:     "Another User",
		}

		_, err := cmdHandler.Register(ctx, cmd)
		if err == nil {
			t.Error("Should return error for duplicate email")
		}
	})

	t.Run("login with correct credentials", func(t *testing.T) {
		cmd := application.LoginCommand{
			Email:    "test@example.com",
			Password: "password123",
		}

		token, err := cmdHandler.Login(ctx, cmd)
		if err != nil {
			t.Errorf("Login failed: %v", err)
		}
		if token == "" {
			t.Error("Token should not be empty")
		}
	})

	t.Run("login with wrong password", func(t *testing.T) {
		cmd := application.LoginCommand{
			Email:    "test@example.com",
			Password: "wrongpassword",
		}

		_, err := cmdHandler.Login(ctx, cmd)
		if err == nil {
			t.Error("Should return error for wrong password")
		}
	})
}

func TestPasswordReset(t *testing.T) {
	repo := infrastructure.NewMemoryRepo()
	hasher := &infrastructure.PasswordHasher{}
	jwtService := infrastructure.NewJWTService("test-secret-key")
	emailService := &infrastructure.EmailMock{}

	cmdHandler := &application.CommandHandler{
		Repo:   repo,
		Hasher: hasher,
		JWT:    jwtService,
		Mail:   emailService,
	}

	ctx := context.Background()

	registerCmd := application.RegisterCommand{
		Email:    "reset@example.com",
		Password: "oldpassword123",
		Name:     "Reset User",
	}
	_, err := cmdHandler.Register(ctx, registerCmd)
	if err != nil {
		t.Fatalf("Setup failed: %v", err)
	}

	t.Run("request password reset", func(t *testing.T) {
		cmd := application.RequestPasswordResetCommand{
			Email: "reset@example.com",
		}
		err := cmdHandler.RequestPasswordReset(ctx, cmd)
		if err != nil {
			t.Errorf("Request reset failed: %v", err)
		}
	})

	t.Run("reset with weak password", func(t *testing.T) {
		cmd := application.ResetPasswordCommand{
			Token:       "some-token",
			NewPassword: "123",
		}
		err := cmdHandler.ResetPassword(ctx, cmd)
		if err == nil {
			t.Error("Should return error for weak password")
		}
	})
}

func TestValidationRules(t *testing.T) {
	t.Run("validate email", func(t *testing.T) {
		if err := domain.ValidateEmail(""); err == nil {
			t.Error("Empty email should be invalid")
		}

		if err := domain.ValidateEmail("normal@example.com"); err != nil {
			t.Errorf("Valid email should pass: %v", err)
		}
	})

	t.Run("validate password", func(t *testing.T) {
		if err := domain.ValidatePassword("12345"); err == nil {
			t.Error("Short password should be invalid")
		}

		if err := domain.ValidatePassword("password123"); err != nil {
			t.Errorf("Valid password should pass: %v", err)
		}
	})
}

func TestConcurrentAccess(t *testing.T) {
	repo := infrastructure.NewMemoryRepo()
	hasher := &infrastructure.PasswordHasher{}
	jwtService := infrastructure.NewJWTService("test-secret-key")
	emailService := &infrastructure.EmailMock{}

	cmdHandler := &application.CommandHandler{
		Repo:   repo,
		Hasher: hasher,
		JWT:    jwtService,
		Mail:   emailService,
	}

	ctx := context.Background()

	cmd := application.RegisterCommand{
		Email:    "concurrent@example.com",
		Password: "password123",
		Name:     "Concurrent User",
	}
	_, err := cmdHandler.Register(ctx, cmd)
	if err != nil {
		t.Fatalf("Setup failed: %v", err)
	}

	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func() {
			loginCmd := application.LoginCommand{
				Email:    "concurrent@example.com",
				Password: "password123",
			}
			_, err := cmdHandler.Login(ctx, loginCmd)
			if err != nil {
				t.Errorf("Concurrent login failed: %v", err)
			}
			done <- true
		}()
	}

	for i := 0; i < 10; i++ {
		<-done
	}
}
