import 'package:flutter/material.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PrayerService _prayerService = PrayerService();
  final NotificationService _notificationService = NotificationService();

  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _timezoneController = TextEditingController();

  String _method = 'karachi';
  String _madhab = 'hanafi';
  bool _saving = false;

  final List<String> _methods = [
    'karachi',
    'muslim_world_league',
    'egyptian',
    'umm_al_qura',
    'dubai',
    'qatar',
    'kuwait',
    'moonsighting_committee',
    'singapore',
    'turkey',
    'tehran',
    'north_america',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _prayerService.getSettings();
    setState(() {
      _latController.text = settings['latitude'].toString();
      _lngController.text = settings['longitude'].toString();
      _timezoneController.text = settings['timezone'] as String;
      _method = settings['method'] as String;
      _madhab = settings['madhab'] as String;
    });
  }

  Future<void> _save() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid latitude and longitude')),
      );
      return;
    }

    if (_timezoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a timezone')),
      );
      return;
    }

    setState(() => _saving = true);

    await _prayerService.saveSettings(
      latitude: lat,
      longitude: lng,
      timezone: _timezoneController.text.trim(),
      method: _method,
      madhab: _madhab,
    );

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _latController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(
              labelText: 'Latitude',
              hintText: 'e.g. 24.8607',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lngController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(
              labelText: 'Longitude',
              hintText: 'e.g. 67.0011',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timezoneController,
            decoration: const InputDecoration(
              labelText: 'Timezone',
              hintText: 'e.g. Asia/Karachi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
              helperText: 'Use IANA timezone names (Asia/Karachi, America/New_York, etc.)',
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Calculation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _method,
            decoration: const InputDecoration(
              labelText: 'Calculation Method',
              border: OutlineInputBorder(),
            ),
            items: _methods.map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(m.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _madhab,
            decoration: const InputDecoration(
              labelText: 'Madhab (Asr calculation)',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
              DropdownMenuItem(value: 'shafi', child: Text('Shafi / Maliki / Hanbali')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _madhab = value);
            },
          ),
          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Settings'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await _notificationService.showTestNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Test Notification'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tip: You can find latitude & longitude of any city on Google Maps or latlong.net',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
