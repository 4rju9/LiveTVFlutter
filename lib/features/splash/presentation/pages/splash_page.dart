import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_tv/features/home/presentation/pages/home_page.dart';
import 'package:live_tv/features/premium_auth/presentation/cubit/premium_cubit.dart';
import 'package:live_tv/features/premium_auth/presentation/pages/premium_activation_page.dart';
import 'package:live_tv/features/splash/presentation/cubit/update_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final int currentVersionCode = int.parse(packageInfo.buildNumber);

    if (mounted) {
      context.read<UpdateCubit>().checkForUpdates(currentVersionCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        if (state is UpdateFound) {
          _showUpdateDialog(
            context,
            state.updateInfo.url,
            state.updateInfo.releaseNotes,
          );
        } else if (state is NoUpdateFound) {
          _navigateToNext();
        } else if (state is UpdateError) {
          _navigateToNext();
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset('assets/images/livetv.png', width: 150),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String url, List<String> notes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text('New features:\n${notes.join('\n')}'),
        actions: [
          TextButton(
            onPressed: () => _navigateToNext(),
            child: const Text('Later'),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('Update Now')),
        ],
      ),
    );
  }

  void _navigateToNext() {
    final premiumCubit = context.read<PremiumCubit>();
    premiumCubit.checkPremiumStatus();
    if (premiumCubit.state is PremiumStatus &&
        (premiumCubit.state as PremiumStatus).isPremium) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PremiumActivationPage()),
      );
    }
  }
}
