const Map<String, String> kTextEn = {
  // General
  'app_name': 'Employee Portal',
  'cancel': 'Cancel',
  'close': 'Close',
  'later': 'Later',
  'back': 'Back',
  'all': 'All',
  'view': 'View',
  'you': 'there',
  'optional': '{label} (optional)',
  'language': 'Language',
  'theme_toggle': 'Switch light or dark mode',

  // Date and time (comma separated, keep the order)
  'months':
      'January,February,March,April,May,June,July,August,September,October,November,December',
  'months_short': 'JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC',
  'days': 'Mon,Tue,Wed,Thu,Fri,Sat,Sun',
  'just_now': 'just now',
  'minutes_ago': '{n} min ago',
  'hours_ago': '{n} hr ago',
  'yesterday': 'yesterday',
  'days_ago': '{n} days ago',

  // Employee data
  'full_name': 'Full name',
  'nik': 'Employee ID (NIK)',
  'finger_no': 'Fingerprint no.',
  'department': 'Department',
  'position': 'Position',
  'password': 'Password',

  // Sign in and sign up
  'auth_hello_1': 'Welcome back.',
  'auth_hello_2': 'Sign in to continue.',
  'auth_join_1': "Let's get started.",
  'auth_join_2': 'Create your account first.',
  'show_password': 'Show password',
  'hide_password': 'Hide password',
  'sign_in': 'Sign in',
  'sign_up': 'Sign up',
  'have_account': 'Already have an account? Sign in',
  'no_account': "Don't have an account? Sign up",
  'demo_hint':
      'Try the demo account: fingerprint no. {finger}, password {password}. Tap to fill it in.',
  'err_wrong_password': 'Wrong password.',
  'err_finger_unknown': 'This fingerprint no. is not registered.',
  'err_finger_required': 'Fingerprint no. is required.',
  'err_finger_taken': 'This fingerprint no. is already registered.',
  'err_name_required': 'Name is required.',
  'err_password_short': 'Password must be at least 6 characters.',

  // Menu
  'nav_home': 'Home',
  'nav_news': 'News',
  'nav_events': 'Events',
  'nav_survey': 'Surveys',
  'nav_leave': 'Leave',
  'nav_payslip': 'Payslips',
  'nav_profile': 'Profile',
  'nav_services': 'Services',
  'search_news': 'Search news',
  'search_hint': 'Search news, then press Enter',
  'notifications': 'Notifications',
  'no_notifications': 'No notifications yet.',

  // In-app notification list
  'note_payslip_ready': "Last month's payslip is available.",
  'note_new_survey': 'A new survey is waiting for your answers.',
  'note_event_join': 'You signed up for "{title}".',
  'note_event_cancel': 'You are no longer going to "{title}".',
  'note_survey_thanks': 'Thank you for completing "{title}".',

  // Home
  'greet_morning': 'Good morning',
  'greet_midday': 'Good afternoon',
  'greet_afternoon': 'Good afternoon',
  'greet_night': 'Good evening',
  'home_question': "What's new today?",
  'latest_payslip': 'Latest payslip',
  'next_events': 'Upcoming events',
  'no_events_scheduled': 'No events scheduled yet.',
  'voice_matters': 'Your voice matters',
  'all_surveys_done': 'You have completed every survey. Thank you!',
  'only_minutes': 'Only {n} min',
  'fill_survey': 'Take survey',
  'see_all_news': 'See all news',
  'dont_miss': "DON'T MISS THIS",

  // News
  'news_subtitle': 'The latest from the company',
  'cat_Semua': 'All',
  'cat_Berita': 'News',
  'cat_Pengumuman': 'Announcement',
  'cat_Umum': 'General',
  'no_news_match': 'No matching news.',
  'like': 'Like',
  'comments': 'Comments',
  'first_comment': 'Be the first to comment.',
  'write_comment': 'Write a comment',
  'send_comment': 'Send comment',

  // Events
  'events_subtitle': "Tap a date to see that day's events",
  'prev_month': 'Previous month',
  'next_month': 'Next month',
  'no_one_registered': 'No one has signed up yet',
  'people_going': '{n} going',
  'registered': 'Going',
  'join': 'Join',
  'events_on': 'Events on {date}',
  'events_in': 'All events in {month}',
  'no_events_date': 'No events on this date.',
  'no_events_month': 'No events this month.',

  // Services
  'services_subtitle': 'Everything you need in one place',
  'leave_left': '{n} days left',
  'payslip_sub': 'View your monthly pay details',
  'surveys_waiting': '{n} surveys waiting',
  'all_filled': 'All completed',

  // Leave
  'leave_remaining': 'Annual leave remaining',
  'leave_of': 'of {n} days',
  'leave_quota': 'Annual leave allowance',
  'leave_used': 'Used',
  'leave_rest': 'Remaining',
  'n_days': '{n} days',
  'leave_info':
      'This page only shows your remaining leave. Leave requests are not made in the app.',

  // Payslips
  'payslip_subtitle': 'The figures below are sample data',
  'show_amounts': 'Show amounts',
  'received': 'Net: {v}',
  'earnings': 'EARNINGS',
  'deductions': 'DEDUCTIONS',
  'total_earnings': 'Total earnings',
  'total_deductions': 'Total deductions',
  'net_pay': 'Net pay',

  // Surveys
  'survey_subtitle': 'Your voice helps make the company better',
  'survey_meta': '{n} questions, about {m} min',
  'survey_done': 'Completed',
  'question_missing': 'Question {n} has not been answered.',
  'answers_saved': 'Your answers were saved. Thank you!',
  'rating_of': '{n} of 5',
  'your_answer': 'Your answer (optional)',
  'send_answers': 'Submit answers',

  // Profile
  'not_set': 'Not set',
  'appearance': 'Appearance',
  'theme_system': 'Follow device',
  'theme_light': 'Light',
  'theme_dark': 'Dark',
  'logout': 'Log out',
  'logout_title': 'Log out of your account?',
  'logout_body': 'You will need to sign in again to use the app.',

  // Notification test
  'notif_test_desc':
      'Send a test notification to check that notifications work on this device.',
  'notif_test_button': 'Test notification',
  'notif_test_title': 'Test notification',
  'notif_test_body': 'Notifications are working on this device.',
  'notif_sent': 'Test notification sent. Check your notification panel.',
  'notif_denied':
      "Notification permission was denied. Turn on this app's notifications in your device or browser settings.",
  'notif_unsupported':
      'Notifications are not supported on this device or browser.',
  'notif_insecure':
      'Notifications only work when the app is opened over HTTPS.',
  'notif_failed': 'The notification could not be sent.',

  // App update
  'about_app': 'App',
  'app_version': 'Version {v}',
  'check_update': 'Check for updates',
  'update_title': 'Update available',
  'update_body':
      'Version {new} is available. This phone has version {current}. Update now?',
  'update_now': 'Update',
  'update_downloading': 'Downloading update… {p}%',
  'update_installing':
      'Download complete. Follow the install screen to finish the update.',
  'update_failed': 'The update could not be downloaded. Try again later.',
  'update_permission':
      'Allow this app to install updates in your phone settings, then try again.',
  'up_to_date': 'The app is up to date.',
  'update_check_failed':
      'Could not check for updates. Check your internet connection.',
  'update_unsupported': 'In-app updates are only available on Android.',
};
