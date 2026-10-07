import '../models/trend_model.dart';
import '../models/trend_data_point_model.dart';
import '../models/activity_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

/// Realistic sample seed data for Trend Curve.
class SampleData {
  SampleData._();

  static UserModel get user => UserModel(
        id: 'usr_01',
        name: 'Alex Rivera',
        email: 'alex.rivera@trendcurve.io',
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      );

  static List<TrendModel> get initialTrends {
    final now = DateTime.now();

    return [
      // 1. Monthly Revenue
      TrendModel(
        id: 'tr_rev_01',
        name: 'Monthly Revenue',
        description: 'Tracking recurring software and consulting revenue',
        category: 'Business',
        unit: '₹',
        currentValue: 91000,
        previousValue: 82500,
        targetValue: 100000,
        startDate: now.subtract(const Duration(days: 180)),
        frequency: 'Monthly',
        iconName: 'business_center',
        colorHex: '#6366F1',
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(days: 2)),
        dataPoints: [
          TrendDataPointModel(
            id: 'dp_rev_1',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 180)),
            value: 54000,
            note: 'Initial month launch',
            createdAt: now.subtract(const Duration(days: 180)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_2',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 150)),
            value: 62000,
            note: 'Client retainer secured',
            createdAt: now.subtract(const Duration(days: 150)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_3',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 120)),
            value: 59000,
            note: 'Seasonal summer dip',
            createdAt: now.subtract(const Duration(days: 120)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_4',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 90)),
            value: 68500,
            note: 'Launched pro tier subscriptions',
            createdAt: now.subtract(const Duration(days: 90)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_5',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 60)),
            value: 74200,
            note: 'Enterprise inbound closed',
            createdAt: now.subtract(const Duration(days: 60)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_6',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 30)),
            value: 82500,
            note: 'Expansion revenue',
            createdAt: now.subtract(const Duration(days: 30)),
          ),
          TrendDataPointModel(
            id: 'dp_rev_7',
            trendId: 'tr_rev_01',
            date: now.subtract(const Duration(days: 2)),
            value: 91000,
            note: 'Current monthly total',
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),

      // 2. Website Visitors
      TrendModel(
        id: 'tr_vis_02',
        name: 'Website Visitors',
        description: 'Monthly active web visitors across all domains',
        category: 'Technology',
        unit: 'visits',
        currentValue: 43500,
        previousValue: 39800,
        targetValue: 50000,
        startDate: now.subtract(const Duration(days: 120)),
        frequency: 'Monthly',
        iconName: 'devices',
        colorHex: '#06B6D4',
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 3)),
        dataPoints: [
          TrendDataPointModel(
            id: 'dp_vis_1',
            trendId: 'tr_vis_02',
            date: now.subtract(const Duration(days: 120)),
            value: 18500,
            note: 'SEO audit baseline',
            createdAt: now.subtract(const Duration(days: 120)),
          ),
          TrendDataPointModel(
            id: 'dp_vis_2',
            trendId: 'tr_vis_02',
            date: now.subtract(const Duration(days: 90)),
            value: 24800,
            note: 'Tech blog article indexed',
            createdAt: now.subtract(const Duration(days: 90)),
          ),
          TrendDataPointModel(
            id: 'dp_vis_3',
            trendId: 'tr_vis_02',
            date: now.subtract(const Duration(days: 60)),
            value: 31200,
            note: 'Featured on Hacker News',
            createdAt: now.subtract(const Duration(days: 60)),
          ),
          TrendDataPointModel(
            id: 'dp_vis_4',
            trendId: 'tr_vis_02',
            date: now.subtract(const Duration(days: 30)),
            value: 39800,
            note: 'Product Hunt top 3 day',
            createdAt: now.subtract(const Duration(days: 30)),
          ),
          TrendDataPointModel(
            id: 'dp_vis_5',
            trendId: 'tr_vis_02',
            date: now.subtract(const Duration(days: 3)),
            value: 43500,
            note: 'High organic search volume',
            createdAt: now.subtract(const Duration(days: 3)),
          ),
        ],
      ),

      // 3. Study Hours
      TrendModel(
        id: 'tr_std_03',
        name: 'Study Hours',
        description: 'Weekly deep work and learning sprint hours',
        category: 'Education',
        unit: 'hrs',
        currentValue: 36,
        previousValue: 30,
        targetValue: 40,
        startDate: now.subtract(const Duration(days: 42)),
        frequency: 'Weekly',
        iconName: 'school',
        colorHex: '#8B5CF6',
        createdAt: now.subtract(const Duration(days: 42)),
        updatedAt: now.subtract(const Duration(days: 1)),
        dataPoints: [
          TrendDataPointModel(
            id: 'dp_std_1',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 42)),
            value: 18,
            note: 'Week 1 ramp up',
            createdAt: now.subtract(const Duration(days: 42)),
          ),
          TrendDataPointModel(
            id: 'dp_std_2',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 35)),
            value: 22,
            note: 'Algorithms study',
            createdAt: now.subtract(const Duration(days: 35)),
          ),
          TrendDataPointModel(
            id: 'dp_std_3',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 28)),
            value: 25,
            note: 'System architecture books',
            createdAt: now.subtract(const Duration(days: 28)),
          ),
          TrendDataPointModel(
            id: 'dp_std_4',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 21)),
            value: 28,
            note: 'Full weekend hackathon',
            createdAt: now.subtract(const Duration(days: 21)),
          ),
          TrendDataPointModel(
            id: 'dp_std_5',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 14)),
            value: 30,
            note: 'Continuous focus blocks',
            createdAt: now.subtract(const Duration(days: 14)),
          ),
          TrendDataPointModel(
            id: 'dp_std_6',
            trendId: 'tr_std_03',
            date: now.subtract(const Duration(days: 1)),
            value: 36,
            note: 'Peak week ahead of exams',
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),

      // 4. Fitness Progress (Weight tracking)
      TrendModel(
        id: 'tr_fit_04',
        name: 'Fitness Weight',
        description: 'Tracking body recomposition progress',
        category: 'Health',
        unit: 'kg',
        currentValue: 76.5,
        previousValue: 77.9,
        targetValue: 72.0,
        startDate: now.subtract(const Duration(days: 56)),
        frequency: 'Weekly',
        iconName: 'favorite',
        colorHex: '#EF4444',
        createdAt: now.subtract(const Duration(days: 56)),
        updatedAt: now.subtract(const Duration(days: 4)),
        dataPoints: [
          TrendDataPointModel(
            id: 'dp_fit_1',
            trendId: 'tr_fit_04',
            date: now.subtract(const Duration(days: 56)),
            value: 82.5,
            note: 'Starting weight check-in',
            createdAt: now.subtract(const Duration(days: 56)),
          ),
          TrendDataPointModel(
            id: 'dp_fit_2',
            trendId: 'tr_fit_04',
            date: now.subtract(const Duration(days: 42)),
            value: 80.9,
            note: 'Cardio routine locked',
            createdAt: now.subtract(const Duration(days: 42)),
          ),
          TrendDataPointModel(
            id: 'dp_fit_3',
            trendId: 'tr_fit_04',
            date: now.subtract(const Duration(days: 28)),
            value: 79.5,
            note: 'Clean diet consistency',
            createdAt: now.subtract(const Duration(days: 28)),
          ),
          TrendDataPointModel(
            id: 'dp_fit_4',
            trendId: 'tr_fit_04',
            date: now.subtract(const Duration(days: 14)),
            value: 77.9,
            note: 'Strength plateau passed',
            createdAt: now.subtract(const Duration(days: 14)),
          ),
          TrendDataPointModel(
            id: 'dp_fit_5',
            trendId: 'tr_fit_04',
            date: now.subtract(const Duration(days: 4)),
            value: 76.5,
            note: 'Solid 6kg fat loss marker',
            createdAt: now.subtract(const Duration(days: 4)),
          ),
        ],
      ),

      // 5. Social Followers
      TrendModel(
        id: 'tr_soc_05',
        name: 'Social Community',
        description: 'Total audience across YouTube and Twitter/X',
        category: 'Social',
        unit: 'users',
        currentValue: 23400,
        previousValue: 21800,
        targetValue: 25000,
        startDate: now.subtract(const Duration(days: 90)),
        frequency: 'Weekly',
        iconName: 'share',
        colorHex: '#EC4899',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 5)),
        dataPoints: [
          TrendDataPointModel(
            id: 'dp_soc_1',
            trendId: 'tr_soc_05',
            date: now.subtract(const Duration(days: 90)),
            value: 12400,
            note: 'Milestone 10k passed',
            createdAt: now.subtract(const Duration(days: 90)),
          ),
          TrendDataPointModel(
            id: 'dp_soc_2',
            trendId: 'tr_soc_05',
            date: now.subtract(const Duration(days: 60)),
            value: 16800,
            note: 'Viral video published',
            createdAt: now.subtract(const Duration(days: 60)),
          ),
          TrendDataPointModel(
            id: 'dp_soc_3',
            trendId: 'tr_soc_05',
            date: now.subtract(const Duration(days: 30)),
            value: 20100,
            note: 'Collaboration release',
            createdAt: now.subtract(const Duration(days: 30)),
          ),
          TrendDataPointModel(
            id: 'dp_soc_4',
            trendId: 'tr_soc_05',
            date: now.subtract(const Duration(days: 10)),
            value: 21800,
            note: 'Newsletter mentions',
            createdAt: now.subtract(const Duration(days: 10)),
          ),
          TrendDataPointModel(
            id: 'dp_soc_5',
            trendId: 'tr_soc_05',
            date: now.subtract(const Duration(days: 5)),
            value: 23400,
            note: 'Approaching 25k target!',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
    ];
  }

  static List<ActivityModel> get initialActivities {
    final now = DateTime.now();
    return [
      ActivityModel(
        id: 'act_01',
        title: 'Revenue data updated',
        description: 'Added data point ₹91,000 for Monthly Revenue',
        timestamp: now.subtract(const Duration(minutes: 45)),
        iconName: 'trending_up',
        trendId: 'tr_rev_01',
      ),
      ActivityModel(
        id: 'act_02',
        title: 'Monthly target reached',
        description: 'Study Hours achieved 90% of weekly goal',
        timestamp: now.subtract(const Duration(hours: 4)),
        iconName: 'verified',
        trendId: 'tr_std_03',
      ),
      ActivityModel(
        id: 'act_03',
        title: 'Website Visitors surged',
        description: 'Traffic up by 9.3% across product landing pages',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        iconName: 'analytics',
        trendId: 'tr_vis_02',
      ),
      ActivityModel(
        id: 'act_04',
        title: 'New trend created',
        description: 'Created trend "Fitness Weight" under Health',
        timestamp: now.subtract(const Duration(days: 3)),
        iconName: 'add_chart',
        trendId: 'tr_fit_04',
      ),
      ActivityModel(
        id: 'act_05',
        title: 'Exported analytics summary',
        description: 'Downloaded backup dataset in JSON format',
        timestamp: now.subtract(const Duration(days: 5)),
        iconName: 'download',
      ),
    ];
  }

  static List<NotificationModel> get initialNotifications {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_01',
        title: 'Trend Milestone Reached!',
        message: 'Monthly Revenue reached ₹91,000, 91% of your target!',
        type: NotificationType.trendMilestone,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        relatedTrendId: 'tr_rev_01',
      ),
      NotificationModel(
        id: 'notif_02',
        title: 'Weekly Data Reminder',
        message: "Time to log this week's Study Hours to keep your streak alive.",
        type: NotificationType.dataReminder,
        timestamp: now.subtract(const Duration(hours: 18)),
        isRead: false,
        relatedTrendId: 'tr_std_03',
      ),
      NotificationModel(
        id: 'notif_03',
        title: 'Goal Nearing Completion',
        message: 'Social Community is only 1,600 users away from 25,000!',
        type: NotificationType.goalReached,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        relatedTrendId: 'tr_soc_05',
      ),
      NotificationModel(
        id: 'notif_04',
        title: 'System Update',
        message: 'Trend Curve v1.0.0 is live with interactive charts and export support.',
        type: NotificationType.systemNotification,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}
