import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = PrayerService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  Timer? _timer;
  String _currentTime = '';
  String? _nextPrayer;
  Duration _timeUntilNext = Duration.zero;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClock();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final times = await _prayerService.getTodayPrayerTimes();
      await _notificationService.schedulePrayerNotifications(times);

      setState(() {
        _prayerTimes = times;
        _loading = false;
      });
      _updateClock();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(now);

      if (_prayerTimes != null) {
        _nextPrayer = _prayerService.getNextPrayerName(_prayerTimes!);
        final nextTime = _prayerService.getNextPrayerTime(_prayerTimes!);
        if (nextTime != null) {
          _timeUntilNext = nextTime.difference(now);
          if (_timeUntilNext.isNegative) {
            _timeUntilNext = Duration.zero;
          }
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islam Azan Desktop'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadPrayerTimes,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadPrayerTimes(); // reload after settings change
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading prayer times', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loadPrayerTimes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrayerTimes,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Current Time Card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Current Time',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentTime,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Next Prayer Card
                      if (_nextPrayer != null)
                        Card(
                          color: theme.colorScheme.primaryContainer,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  'Next Prayer',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _nextPrayer!,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'in ${_formatDuration(_timeUntilNext)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Prayer Times List
                      Text(
                        "Today's Prayer Times",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_prayerTimes != null) ...[
                        _buildPrayerTile('Fajr', _prayerTimes!.fajr, theme),
                        _buildPrayerTile('Sunrise', _prayerTimes!.sunrise, theme, isSunrise: true),
                        _buildPrayerTile('Dhuhr', _prayerTimes!.dhuhr, theme),
                        _buildPrayerTile('Asr', _prayerTimes!.asr, theme),
                        _buildPrayerTile('Maghrib', _prayerTimes!.maghrib, theme),
                        _buildPrayerTile('Isha', _prayerTimes!.isha, theme),
                      ],

                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Notifications are scheduled for remaining prayers',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrayerTile(String name, DateTime time, ThemeData theme, {bool isSunrise = false}) {
    final isNext = name == _nextPrayer;
    final formatted = DateFormat('hh:mm a').format(time);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isNext ? theme.colorScheme.secondaryContainer : null,
      child: ListTile(
        leading: Icon(
          isSunrise ? Icons.wb_sunny_outlined : Icons.mosque_outlined,
          color: isNext ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.primary,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
            color: isNext ? theme.colorScheme.onSecondaryContainer : null,
          ),
        ),
        trailing: Text(
          formatted,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isNext ? theme.colorScheme.onSecondaryContainer : null,
          ),
        ),
      ),
    );
  }
}
