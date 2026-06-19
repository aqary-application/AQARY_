/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/services.dart';
import '../../models/models.dart'; // تأكد من مسار النماذج
// import '../../widgets/provider_nav_bar.dart'; // قم بفك التعليق إذا كان لديك شريط تنقل خاص بمقدم الخدمة

class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() => _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState extends State<ProviderNotificationsScreen> {
  String? get _uid => Firebase.auth.currentUser?.uid;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      NotificationService.instance.watchUnreadCount(_uid!).listen(
        (count) {
          if (mounted) setState(() => _unreadCount = count);
        },
      );
    }
  }

  // ... (نفس Imports السابقة)

  Future<void> _onNotificationTap(AppNotification n) async {
    await NotificationService.instance.markAsRead(n.id);
    if (!mounted) return;

    // بما أن الإشعارات من الأدمن فقط، التوجيه يكون بسيطاً
    switch (n.type) {
      case 'admin_alert':
        // يمكنك توجيهه لصفحة "إعلانات الأدمن" أو صفحة تفاصيل معينة
        break;
      case 'account_status':
        // مثلاً توجيهه لصفحة ملفه الشخصي ليرى حالة التوثيق
        break;
      default:
        // في حال لم يكن هناك توجيه، لا تفعل شيئاً
        break;
    }
  }

  IconData _iconForType(String type) => switch (type) {
        'admin_alert' => Icons.campaign_rounded, // أيقونة إعلان
        'account_status' => Icons.verified_user_rounded, // أيقونة توثيق
        _ => Icons.notifications_rounded,
      };

  Color _colorForType(String type) => switch (type) {
        'admin_alert' => AppTheme.primary,
        'account_status' => AppTheme.success,
        _ => AppTheme.accent,
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // خلفية ناعمة جداً تبرز البطاقات
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppTheme.primary,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => NotificationService.instance.markAllAsRead(_uid!),
            icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () => NotificationService.instance.deleteAllNotifications(_uid!),
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
            tooltip: 'Delete all',
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<AppNotification>>(
            stream: NotificationService.instance.watchNotifications(_uid!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: AppTheme.error),
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = notifications[index];

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => NotificationService.instance.deleteNotification(n.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(16), // حواف أكثر نعومة
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                    ),
                    child: _buildNotificationCard(n),
                  );
                },
              );
            },
          ),

          // الناف بار (قم بتعديله ليناسب ProviderNavBar إذا كان موجوداً لديك)
          /*
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ProviderNavBar(
              currentIndex: 3, // تعديل حسب ترتيب صفحة الإشعارات
              unreadCount: _unreadCount,
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 60,
              color: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have no new notifications.',
            style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : AppTheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: n.isRead ? Colors.transparent : AppTheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: n.isRead
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [], // بدون ظل إذا كان غير مقروء لتعزيز تأثير الخلفية الملونة
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onNotificationTap(n),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الأيقونة الدائرية
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _colorForType(n.type).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(n.type),
                    color: _colorForType(n.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // النصوص (العنوان والتفاصيل)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(n.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.body,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: n.isRead ? AppTheme.textMuted : AppTheme.textDark.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (n.linkedId != null && n.type != 'broadcast') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'View details', // نص عام أو يمكن تخصيصه حسب النوع
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primary),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // نقطة الإشعار غير المقروء
                if (!n.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 12, top: 4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
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

*/