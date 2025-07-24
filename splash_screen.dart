import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_particles_widget.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Cargando configuración...';
  double _progress = 0.0;

  final List<Map<String, dynamic>> _initializationSteps = [
    {
      'message': 'Verificando autenticación...',
      'duration': 800,
      'progress': 0.2,
    },
    {
      'message': 'Cargando preferencias de usuario...',
      'duration': 600,
      'progress': 0.4,
    },
    {
      'message': 'Inicializando modelos de IA...',
      'duration': 1000,
      'progress': 0.7,
    },
    {
      'message': 'Preparando conversaciones...',
      'duration': 500,
      'progress': 0.9,
    },
    {
      'message': 'Finalizando configuración...',
      'duration': 400,
      'progress': 1.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Execute initialization steps
      for (int i = 0; i < _initializationSteps.length; i++) {
        final step = _initializationSteps[i];

        if (mounted) {
          setState(() {
            _initializationStatus = step['message'] as String;
            _progress = step['progress'] as double;
          });
        }

        await Future.delayed(Duration(milliseconds: step['duration'] as int));

        // Simulate actual initialization tasks
        await _performInitializationStep(i);
      }

      // Complete initialization
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationStatus = '¡Listo para conversar!';
        });
      }

      // Navigate after brief delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await _fadeController.forward();
        _navigateToNextScreen();
      }
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<void> _performInitializationStep(int stepIndex) async {
    switch (stepIndex) {
      case 0:
        // Check authentication status
        await _checkAuthenticationStatus();
        break;
      case 1:
        // Load user preferences
        await _loadUserPreferences();
        break;
      case 2:
        // Initialize AI model configurations
        await _initializeAIModels();
        break;
      case 3:
        // Prepare cached conversations
        await _prepareCachedConversations();
        break;
      case 4:
        // Final setup
        await _finalizeSetup();
        break;
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    // Simulate authentication check
    await Future.delayed(const Duration(milliseconds: 200));
    // In real implementation, check stored tokens, validate sessions
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading user preferences
    await Future.delayed(const Duration(milliseconds: 150));
    // In real implementation, load theme, language, AI model preferences
  }

  Future<void> _initializeAIModels() async {
    // Simulate AI model initialization
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, initialize AI API connections, load model configs
  }

  Future<void> _prepareCachedConversations() async {
    // Simulate conversation cache preparation
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, load recent conversations, prepare offline data
  }

  Future<void> _finalizeSetup() async {
    // Simulate final setup
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, complete any remaining initialization
  }

  void _handleInitializationError(dynamic error) {
    if (mounted) {
      setState(() {
        _initializationStatus = 'Error de inicialización';
        _isInitializing = false;
      });

      // Show retry option after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showRetryDialog();
        }
      });
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Error de Conexión',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'No se pudo inicializar la aplicación. Verifica tu conexión a internet e inténtalo de nuevo.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _progress = 0.0;
      _initializationStatus = 'Reintentando...';
    });
    _initializeApp();
  }

  void _navigateToNextScreen() {
    // Navigate to chat screen
    Navigator.pushReplacementNamed(context, '/chat-home');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BackgroundGradientWidget(
          child: SafeArea(
            child: Stack(
              children: [
                // Animated particles background
                const Positioned.fill(
                  child: AiParticlesWidget(),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer to push content up slightly
                      SizedBox(height: 10.h),

                      // Animated logo
                      const AnimatedLogoWidget(),

                      SizedBox(height: 4.h),

                      // App title
                      Text(
                        'Sphiny AI',
                        style: AppTheme.lightTheme.textTheme.headlineMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 6.w,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // Subtitle
                      Text(
                        'Tu compañero inteligente de conversación',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 3.5.w,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Flexible spacer
                      const Spacer(),

                      // Loading section
                      if (_isInitializing) ...[
                        const LoadingIndicatorWidget(),
                        SizedBox(height: 2.h),

                        // Progress bar
                        Container(
                          width: 60.w,
                          height: 0.5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentLight,
                                    AppTheme.primaryLight,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Status text
                        Text(
                          _initializationStatus,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 3.w,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        // Success state
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.accentLight.withValues(alpha: 0.2),
                            border: Border.all(
                              color:
                                  AppTheme.accentLight.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: AppTheme.accentLight,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                _initializationStatus,
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 3.5.w,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 8.h),

                      // Version info
                      Text(
                        'Versión 1.0.0',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 2.5.w,
                        ),
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
