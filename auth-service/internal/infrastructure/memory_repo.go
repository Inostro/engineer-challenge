package infrastructure

import (
	"context"
	"errors"
	"sync"

	"auth-service/internal/domain"
)

type MemoryRepo struct {
	mu           sync.RWMutex
	users        map[string]*domain.User
	usersByEmail map[string]*domain.User
	resetTokens  map[string]*domain.ResetToken
}

func NewMemoryRepo() *MemoryRepo {
	return &MemoryRepo{
		users:        make(map[string]*domain.User),
		usersByEmail: make(map[string]*domain.User),
		resetTokens:  make(map[string]*domain.ResetToken),
	}
}

func (r *MemoryRepo) Create(ctx context.Context, user *domain.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.users[user.ID] = user
	r.usersByEmail[user.Email] = user
	return nil
}

func (r *MemoryRepo) FindByEmail(ctx context.Context, email string) (*domain.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	user, ok := r.usersByEmail[email]
	if !ok {
		return nil, errors.New("not found")
	}
	return user, nil
}

func (r *MemoryRepo) FindByID(ctx context.Context, id string) (*domain.User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	user, ok := r.users[id]
	if !ok {
		return nil, errors.New("not found")
	}
	return user, nil
}

func (r *MemoryRepo) Update(ctx context.Context, user *domain.User) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.users[user.ID] = user
	r.usersByEmail[user.Email] = user
	return nil
}

func (r *MemoryRepo) SaveResetToken(ctx context.Context, token *domain.ResetToken) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.resetTokens[token.Token] = token
	return nil
}

func (r *MemoryRepo) FindResetToken(ctx context.Context, token string) (*domain.ResetToken, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	t, ok := r.resetTokens[token]
	if !ok {
		return nil, errors.New("not found")
	}
	return t, nil
}

func (r *MemoryRepo) MarkResetTokenUsed(ctx context.Context, token string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	t, ok := r.resetTokens[token]
	if !ok {
		return errors.New("not found")
	}
	t.Used = true
	return nil
}
