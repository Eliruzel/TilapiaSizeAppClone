import 'package:flutter/material.dart';

class MobileAuthPage extends StatefulWidget {
  const MobileAuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.onHome,
    required this.onAbout,
    required this.onHowItWorks,
    required this.onLogin,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHowItWorks;
  final VoidCallback onLogin;

  @override
  State<MobileAuthPage> createState() => _MobileAuthPageState();
}

class _MobileAuthPageState extends State<MobileAuthPage> {
  static const _navy = Color(0xFF102B76);
  static const _headerNavy = Color(0xFF071A4D);
  static const _drawerNavy = Color(0xFF0B1730);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _drawerItem(String title, IconData icon, VoidCallback action) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: const Color(0xFFDCE6FF), size: 19),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: () {
        Navigator.of(context).pop();
        action();
      },
    );
  }

  Widget _drawer() {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.78)
          .clamp(240.0, 320.0)
          .toDouble(),
      backgroundColor: _drawerNavy,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close menu',
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Image.asset(
              'assets/images/app_icon.png',
              width: 128,
              height: 82,
              fit: BoxFit.contain,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerItem('Home', Icons.home_outlined, widget.onHome),
            _drawerItem('About', Icons.info_outline, widget.onAbout),
            _drawerItem('How it works', Icons.help_outline, widget.onHowItWorks),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerItem('Login', Icons.login, widget.onLogin),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: _headerNavy,
        colorScheme: ColorScheme.fromSeed(seedColor: _navy),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _drawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 52,
                color: _headerNavy,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      tooltip: 'Open menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 34,
                        height: 34,
                      ),
                      icon: const Icon(Icons.menu, color: Colors.white),
                    ),
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 38,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Container(
                color: _navy,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        height: 120,
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFDCE6FF),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: widget.form,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
