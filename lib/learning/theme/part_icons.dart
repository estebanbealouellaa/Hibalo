import 'package:flutter/material.dart';

/// lessons.json icon names are Material Symbols Rounded names; each maps to `Icons.<name>_rounded` (unknown = lightbulb).
const Map<String, IconData> kPartIcons = {
  '123': Icons.onetwothree_rounded,
  'abc': Icons.abc_rounded,
  'auto_stories': Icons.auto_stories_rounded,
  'badge': Icons.badge_rounded,
  'block': Icons.block_rounded,
  'calendar_month': Icons.calendar_month_rounded,
  'campaign': Icons.campaign_rounded,
  'chat_bubble': Icons.chat_bubble_rounded,
  'directions_run': Icons.directions_run_rounded,
  'family_restroom': Icons.family_restroom_rounded,
  'favorite': Icons.favorite_rounded,
  'forum': Icons.forum_rounded,
  'groups': Icons.groups_rounded,
  'hearing': Icons.hearing_rounded,
  'help': Icons.help_rounded,
  'home': Icons.home_rounded,
  'lightbulb': Icons.lightbulb_rounded,
  'linear_scale': Icons.linear_scale_rounded,
  'link': Icons.link_rounded,
  'location_on': Icons.location_on_rounded,
  'pause_circle': Icons.pause_circle_rounded,
  'payments': Icons.payments_rounded,
  'person': Icons.person_rounded,
  'public': Icons.public_rounded,
  'restaurant': Icons.restaurant_rounded,
  'rice_bowl': Icons.rice_bowl_rounded,
  'schedule': Icons.schedule_rounded,
  'swap_horiz': Icons.swap_horiz_rounded,
  'table_chart': Icons.table_chart_rounded,
  'text_fields': Icons.text_fields_rounded,
  'turn_right': Icons.turn_right_rounded,
  'waving_hand': Icons.waving_hand_rounded,
  'wb_sunny': Icons.wb_sunny_rounded,
  'work': Icons.work_rounded,
};

/// The icon for a part's `icon` name, or a lightbulb if it isn't mapped.
IconData partIcon(String name) => kPartIcons[name] ?? Icons.lightbulb_rounded;
