package application

import "context"

type QueryHandler struct {
	Repo UserRepository
}

type UserDTO struct {
	ID    string
	Email string
	Name  string
}

func (h *QueryHandler) GetUserByEmail(ctx context.Context, email string) (*UserDTO, error) {
	user, err := h.Repo.FindByEmail(ctx, email)
	if err != nil {
		return nil, err
	}

	return &UserDTO{
		ID:    user.ID,
		Email: user.Email,
		Name:  user.Name,
	}, nil
}
