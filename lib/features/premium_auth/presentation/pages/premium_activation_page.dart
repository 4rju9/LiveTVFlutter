import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';

class PremiumActivationPage extends StatefulWidget {
  const PremiumActivationPage({super.key});

  @override
  State<PremiumActivationPage> createState() => _PremiumActivationPageState();
}

class _PremiumActivationPageState extends State<PremiumActivationPage> {
  final TextEditingController _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    print(">>> SUCCESS: Navigating to Main Home Screen...");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome! Navigating to Home...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<PremiumCubit, PremiumState>(
        listener: (context, state) {
          if (state is PremiumStatus) {
            _navigateToHome();
          } else if (state is PremiumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Hero(
                              tag: 'app_logo',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  'assets/images/livetv.png',
                                  fit: BoxFit.cover,
                                  height: 120,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Unlock Premium',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter your 16-character activation key.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            controller: _keyController,
                            maxLength: 19,
                            inputFormatters: [_LicenseKeyInputFormatter()],
                            decoration: InputDecoration(
                              labelText: 'Activation Key',
                              hintText: 'AAAA-BBBB-CCCC-DDDD',
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                color: theme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              counterText: "", // Hide counter
                            ),
                            style: const TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a key';
                              }
                              if (value.length != 19) {
                                return 'Key must be complete (16 characters)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            onPressed: state is PremiumLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      final cleanKey = _keyController.text
                                          .replaceAll('-', '');
                                      context
                                          .read<PremiumCubit>()
                                          .activatePremium(cleanKey);
                                    }
                                  },
                            child: const Text(
                              'ACTIVATE NOW',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: state is PremiumLoading
                                ? null
                                : () {
                                    context.read<PremiumCubit>().continueFree();
                                  },
                            child: Text(
                              'Continue with Ads (Free Version)',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (state is PremiumLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LicenseKeyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final oldText = oldValue.text;
    if (newText.length < oldText.length) {
      String cleanOld = oldText.replaceAll('-', '');
      if (cleanOld.isNotEmpty &&
          (cleanOld.length % 4 == 0) &&
          oldText.endsWith('-')) {
        String cleanNew = cleanOld.substring(0, cleanOld.length - 1);
        return _formatAndWrap(cleanNew);
      }
    }
    String cleanText = newText.replaceAll('-', '').toUpperCase();
    if (cleanText.length > 16) cleanText = cleanText.substring(0, 16);
    return _formatAndWrap(cleanText);
  }

  TextEditingValue _formatAndWrap(String cleanText) {
    final buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(cleanText[i]);
    }
    String finalResult = buffer.toString();
    return TextEditingValue(
      text: finalResult,
      selection: TextSelection.collapsed(offset: finalResult.length),
    );
  }
}
