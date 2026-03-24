package domain

import (
	"errors"
	"time"
)

type User struct {
	ID        string
	Email     string
	Password  string // хеш
	Name      string
	Active    bool
	CreatedAt time.Time
}

type ResetToken struct {
	Token     string
	UserID    string
	ExpiresAt time.Time
	Used      bool
}

func ValidateEmail(email string) error {
	if email == "" {
		return errors.New("email required")
	}

	if len(email) < 3 {
		return errors.New("email too short")
	}
	return nil
}

func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters")
	}
	return nil
}

func (u *User) CanLogin() error {
	if !u.Active {
		return errors.New("account is blocked")
	}
	return nil
}
