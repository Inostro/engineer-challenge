package infrastructure

import "fmt"

type EmailMock struct{}

func (e *EmailMock) SendResetPassword(email, token string) error {
	fmt.Printf("[EMAIL MOCK] Reset password for %s: token=%s\n", email, token)
	return nil
}
