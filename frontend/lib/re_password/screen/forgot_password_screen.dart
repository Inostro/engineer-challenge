import 'package:flutter/material.dart';
import 'package:template/re_password/logic/forgot_password_view_model.dart';
import 'package:template/widgets/widgets.dart';

class RePasswordScreen extends StatefulWidget {
  const RePasswordScreen({super.key});

  @override
  State<RePasswordScreen> createState() => _RePasswordScreenState();
}

class _RePasswordScreenState extends State<RePasswordScreen> {
  late final ForgotPasswordViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }
  
  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _viewModel.goBack(context),
        ),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: StreamBuilder<ForgotPasswordState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? const ForgotPasswordState();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Icon and description
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Email field
                    CustomTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Error message
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Success message
                    if (state.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.successMessage!,
                          style: const TextStyle(color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Send reset email button
                    LoadingButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _viewModel.sendResetEmail(
                            context,
                            _emailController.text.trim(),
                          );
                        }
                      },
                      isLoading: state.status == ForgotPasswordStatus.loading,
                      text: 'Send Reset Link',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}