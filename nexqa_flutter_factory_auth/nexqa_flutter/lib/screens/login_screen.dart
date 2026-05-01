import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _factoryController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _factoryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().signIn(
            factoryName: _factoryController.text,
            password: _passwordController.text,
          );
    } catch (error) {
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          if (isDark) ...[
            _Orb(color: colors.glowCyan, top: -90, left: -80, opacity: 0.14),
            _Orb(color: colors.glowPurple, top: 230, right: -110, opacity: 0.12),
            _Orb(color: colors.glowPink, bottom: 80, left: -110, opacity: 0.08),
          ],
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.glowCyan, colors.glowPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colors.glowCyan.withOpacity(0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.verified_outlined, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Quality Assurance',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: colors.mutedForeground,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'NexQA',
                              style: GoogleFonts.inter(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: colors.foreground,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      glowColor: colors.glowCyan,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log In',
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: colors.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your factory name and password to continue to inspections.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.5,
                              color: colors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _AuthField(
                            controller: _factoryController,
                            label: 'Factory Name',
                            icon: Icons.factory_outlined,
                            colors: colors,
                          ),
                          const SizedBox(height: 12),
                          _AuthField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            colors: colors,
                            obscureText: true,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: GoogleFonts.inter(
                                color: colors.destructive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New factory?',
                                style: GoogleFonts.inter(color: colors.mutedForeground),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.inter(
                                    color: colors.glowCyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final AppColors colors;
  final bool obscureText;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.colors,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.inter(color: colors.foreground, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: colors.mutedForeground),
        prefixIcon: Icon(icon, color: colors.glowCyan),
        filled: true,
        fillColor: colors.muted.withOpacity(colors.isDark ? 0.65 : 0.55),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.glowCyan, width: 1.3),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double opacity;

  const _Orb({
    required this.color,
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}
