import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Conditionally import platform-specific webview implementations
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../config.dart';
import '../theme.dart';

class ConnectAccountScreen extends StatefulWidget {
  const ConnectAccountScreen({super.key});

  @override
  State<ConnectAccountScreen> createState() => _ConnectAccountScreenState();
}

class _ConnectAccountScreenState extends State<ConnectAccountScreen>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _status = 'Initializing...';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initWebView();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _status = 'Loading... $progress%';
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _status = 'Loading secure page...';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _injectCustomStyling();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
              _status = 'Error: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    _loadStripePage();
  }

  Future<void> _loadStripePage() async {
    try {
      final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Connect Bank Account</title>
    <script src="https://js.stripe.com/v3/"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            -webkit-tap-highlight-color: transparent;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #FAFAFA 0%, #F0F0F0 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px;
            color: #0F0F0F;
        }
        
        .container {
            width: 100%;
            max-width: 400px;
            background: white;
            border-radius: 24px;
            padding: 40px 32px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
            text-align: center;
        }
        
        .icon-wrapper {
            width: 72px;
            height: 72px;
            background: linear-gradient(135deg, #E8642C 0%, #F07A4A 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            box-shadow: 0 8px 24px rgba(232, 100, 44, 0.25);
        }
        
        .icon-wrapper svg {
            width: 36px;
            height: 36px;
            fill: white;
        }
        
        h1 {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }
        
        .subtitle {
            color: #8A8A8A;
            font-size: 15px;
            line-height: 1.5;
            margin-bottom: 32px;
        }
        
        #connect-btn {
            width: 100%;
            padding: 18px 24px;
            font-size: 16px;
            font-weight: 600;
            color: white;
            background: linear-gradient(135deg, #E8642C 0%, #F07A4A 100%);
            border: none;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 16px rgba(232, 100, 44, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        #connect-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(232, 100, 44, 0.4);
        }
        
        #connect-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
        
        #connect-btn .spinner {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .security-note {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #F0F0F0;
            font-size: 13px;
            color: #8A8A8A;
        }
        
        .security-note svg {
            width: 16px;
            height: 16px;
        }
        
        #status {
            margin-top: 20px;
            padding: 16px;
            border-radius: 12px;
            display: none;
            font-size: 14px;
            line-height: 1.5;
        }
        
        #status.success {
            display: block;
            background: #DCFCE7;
            color: #166534;
        }
        
        #status.error {
            display: block;
            background: #FEE2E2;
            color: #991B1B;
        }
        
        .features {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin: 32px 0;
        }
        
        .feature {
            text-align: center;
        }
        
        .feature-icon {
            width: 44px;
            height: 44px;
            background: #F8F8F8;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 8px;
            font-size: 20px;
        }
        
        .feature-label {
            font-size: 12px;
            font-weight: 500;
            color: #525252;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon-wrapper">
            <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1.41 16.09V20h-2.67v-1.93c-1.71-.36-3.16-1.46-3.27-3.4h1.96c.1 1.05.82 1.87 2.65 1.87 1.96 0 2.4-.98 2.4-1.59 0-.83-.44-1.61-2.67-2.14-2.48-.6-4.18-1.62-4.18-3.67 0-1.72 1.39-2.84 3.11-3.21V4h2.67v1.95c1.86.45 2.79 1.86 2.85 3.39H14.3c-.05-1.11-.64-1.87-2.22-1.87-1.5 0-2.4.68-2.4 1.64 0 .84.65 1.39 2.67 1.91s4.18 1.39 4.18 3.91c-.01 1.83-1.38 2.83-3.12 3.16z"/></svg>
        </div>
        
        <h1>Connect Your Bank</h1>
        <p class="subtitle">Link your accounts securely to track your spending automatically</p>
        
        <div class="features">
            <div class="feature">
                <div class="feature-icon">🔒</div>
                <div class="feature-label">Bank-level<br>Security</div>
            </div>
            <div class="feature">
                <div class="feature-icon">⚡</div>
                <div class="feature-label">Instant<br>Sync</div>
            </div>
            <div class="feature">
                <div class="feature-icon">📊</div>
                <div class="feature-label">Smart<br>Insights</div>
            </div>
        </div>
        
        <button id="connect-btn">
            <span>Connect Bank Account</span>
        </button>
        
        <div id="status"></div>
        
        <div class="security-note">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/></svg>
            <span>Protected by 256-bit encryption</span>
        </div>
    </div>

    <script>
        const btn = document.getElementById('connect-btn');
        const status = document.getElementById('status');
        
        function showStatus(msg, type) {
            status.textContent = msg;
            status.className = type;
        }
        
        function setLoading(loading) {
            btn.disabled = loading;
            if (loading) {
                btn.innerHTML = '<div class="spinner"></div><span>Connecting...</span>';
            } else {
                btn.innerHTML = '<span>Connect Bank Account</span>';
            }
        }
        
        btn.addEventListener('click', async () => {
            setLoading(true);
            
            try {
                const configRes = await fetch('/config');
                const { publishableKey } = await configRes.json();
                const stripe = Stripe(publishableKey);
                
                const sessionRes = await fetch('/create-session', { method: 'POST' });
                const sessionData = await sessionRes.json();
                if (sessionData.error) throw new Error(sessionData.error);
                
                const result = await stripe.collectFinancialConnectionsAccounts({
                    clientSecret: sessionData.clientSecret,
                });
                
                if (result.error) throw new Error(result.error.message);
                
                const accounts = result.financialConnectionsSession.accounts;
                
                for (const account of accounts) {
                    const saveRes = await fetch('/save-account', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            accountId: account.id,
                            institution: account.institution_name || null,
                            displayName: account.display_name || null,
                            last4: account.last4 || null,
                        }),
                    });
                    const saveData = await saveRes.json();
                    if (saveData.error) throw new Error(saveData.error);
                }
                
                showStatus('✓ Successfully connected ' + accounts.length + ' account(s)! You can close this window.', 'success');
                
                // Notify Flutter app
                if (window.FlutterChannel) {
                    window.FlutterChannel.postMessage(JSON.stringify({
                        type: 'success',
                        accounts: accounts.length
                    }));
                }
            } catch (err) {
                showStatus('✗ ' + err.message, 'error');
            } finally {
                setLoading(false);
            }
        });
    </script>
</body>
</html>
      ''';

      await _controller.loadHtmlString(htmlContent, baseUrl: apiBaseUrl);
    } catch (e) {
      setState(() {
        _hasError = true;
        _status = 'Failed to load: $e';
      });
    }
  }

  Future<void> _injectCustomStyling() async {
    await _controller.runJavaScript('''
      // Add Flutter channel for communication
      window.FlutterChannel = {
        postMessage: function(message) {
          // This will be handled by JavaScript channels if needed
          console.log('Flutter message:', message);
        }
      };
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connect Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentLight],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(
                                  alpha: 0.3 * _pulseController.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Container(
              color: AppColors.background,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.negativeLight,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: AppColors.negative,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Connection Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          _loadStripePage();
                        },
                        child: const Text('Try Again'),
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
