import 'package:flutter/material.dart';
import '../presentation/tutorial_onboarding/tutorial_onboarding.dart';
import '../presentation/campaign_map/campaign_map.dart';
import '../presentation/real_time_battle/real_time_battle.dart';
import '../presentation/battle_preparation/battle_preparation.dart';
import '../presentation/army_management/army_management.dart';
import '../presentation/research_tree/research_tree.dart';

class AppRoutes {
  static const String initial = '/';
  static const String tutorialOnboarding = '/tutorial-onboarding';
  static const String campaignMap = '/campaign-map';
  static const String battlePreparation = '/battle-preparation';
  static const String realTimeBattle = '/real-time-battle';
  static const String armyManagement = '/army-management';
  static const String researchTree = '/research-tree';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TutorialOnboarding(),
    tutorialOnboarding: (context) => const TutorialOnboarding(),
    campaignMap: (context) => const CampaignMap(),
    battlePreparation: (context) => const BattlePreparation(),
    realTimeBattle: (context) => const RealTimeBattle(),
    armyManagement: (context) => const ArmyManagement(),
    researchTree: (context) => const ResearchTree(),
  };
}
