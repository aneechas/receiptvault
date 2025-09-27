import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileSection(),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Appearance'),
          const _ThemeCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Preferences'),
          const _CurrencyCard(),
          const SizedBox(height: 16),
          const _NotificationsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Data'),
          const _DataManagementCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'About'),
          const _AboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Guest User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Not signed in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentColor),
                    ),
                    child: Text(
                      '${user.subscriptionTier.toUpperCase()} PLAN',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Card(
          child: ListTile(
            leading: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(provider.isDarkMode ? 'Enabled' : 'Disabled'),
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (value) => provider.toggleTheme(),
              activeColor: AppTheme.primaryColor,
            ),
          ),
        );
      },
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.attach_money, color: AppTheme.primaryColor),
            title: const Text('Currency'),
            subtitle: Text('${provider.getCurrencySymbol()} ${provider.currency}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context, provider),
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: AppConstants.supportedCurrencies.entries.map((entry) {
          final isSelected = provider.currency == entry.key;
          return ListTile(
            leading: Icon(
              Icons.radio_button_checked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300],
            ),
            title: Text(entry.key),
            subtitle: Text(entry.value),
            selected: isSelected,
            onTap: () {
              provider.setCurrency(entry.key);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications, color: AppTheme.primaryColor),
                title: const Text('Notifications'),
                subtitle: Text(provider.notificationsEnabled ? 'Enabled' : 'Disabled'),
                trailing: Switch(
                  value: provider.notificationsEnabled,
                  onChanged: (value) => provider.toggleNotifications(),
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              if (provider.notificationsEnabled) ...[
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Budget Alerts'),
                  subtitle: const Text('Notify when approaching budget limit'),
                  value: provider.budgetAlerts,
                  onChanged: (value) => provider.toggleBudgetAlerts(),
                  activeColor: AppTheme.primaryColor,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Receipt Reminders'),
                  subtitle: const Text('Remind to scan receipts daily'),
                  value: provider.receiptReminders,
                  onChanged: (value) => provider.toggleReceiptReminders(),
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DataManagementCard extends StatelessWidget {
  const _DataManagementCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: AppTheme.primaryColor),
            title: const Text('Backup Data'),
            subtitle: const Text('Upload to cloud storage'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.file_download, color: AppTheme.secondaryColor),
            title: const Text('Export Data'),
            subtitle: const Text('Download as CSV or PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all expenses and receipts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Cloud backup is available in Premium and Business plans.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upgrade to Premium to enable backups')),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppTheme.primaryColor),
              title: const Text('CSV (Spreadsheet)'),
              subtitle: const Text('Excel compatible format'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.errorColor),
              title: const Text('PDF (Report)'),
              subtitle: const Text('Professional formatted report'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export available in Premium plan')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your expenses, receipts, and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('Version'),
            subtitle: const Text('1.0.0 (Build 1)'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description, color: AppTheme.secondaryColor),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy screen coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.gavel, color: AppTheme.secondaryColor),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service screen coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.contact_support, color: AppTheme.accentColor),
            title: const Text('Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support contact details coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}