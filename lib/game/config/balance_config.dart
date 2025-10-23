import 'package:json_annotation/json_annotation.dart';

part 'balance_config.g.dart';

@JsonSerializable()
class BalanceConfig {
  @JsonKey(name: 'tick_ms')
  final int tickMs;
  final AgiConfig agi;
  final EconomyConfig economy;
  final Map<String, StructureConfig> structures;
  final Map<String, EnemyConfig> enemies;

  BalanceConfig({
    required this.tickMs,
    required this.agi,
    required this.economy,
    required this.structures,
    required this.enemies,
  });

  factory BalanceConfig.fromJson(Map<String, dynamic> json) =>
      _$BalanceConfigFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceConfigToJson(this);
}

@JsonSerializable()
class AgiConfig {
  @JsonKey(name: 'start_percent')
  final double startPercent;
  @JsonKey(name: 'win_percent')
  final double winPercent;
  @JsonKey(name: 'loss_percent')
  final double lossPercent;
  @JsonKey(name: 'passive_per_tick')
  final double passivePerTick;
  @JsonKey(name: 'wave_clear_bonus')
  final double waveClearBonus;

  AgiConfig({
    required this.startPercent,
    required this.winPercent,
    required this.lossPercent,
    required this.passivePerTick,
    required this.waveClearBonus,
  });

  factory AgiConfig.fromJson(Map<String, dynamic> json) =>
      _$AgiConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AgiConfigToJson(this);
}

@JsonSerializable()
class EconomyConfig {
  @JsonKey(name: 'start_money')
  final int startMoney;
  @JsonKey(name: 'start_energy')
  final int startEnergy;
  @JsonKey(name: 'sell_refund_ratio')
  final double sellRefundRatio;
  @JsonKey(name: 'outage_grace_ms')
  final int outageGraceMs;

  EconomyConfig({
    required this.startMoney,
    required this.startEnergy,
    required this.sellRefundRatio,
    required this.outageGraceMs,
  });

  factory EconomyConfig.fromJson(Map<String, dynamic> json) =>
      _$EconomyConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EconomyConfigToJson(this);
}

@JsonSerializable()
class StructureConfig {
  final int hp;
  final int cost;
  @JsonKey(name: 'upkeep_energy')
  final int upkeepEnergy;
  @JsonKey(name: 'money_per_tick')
  final int moneyPerTick;
  @JsonKey(name: 'energy_per_tick')
  final int energyPerTick;
  final double? range;
  @JsonKey(name: 'fire_interval_ms')
  final int? fireIntervalMs;
  @JsonKey(name: 'projectile_damage')
  final int? projectileDamage;
  @JsonKey(name: 'projectile_speed')
  final double? projectileSpeed;

  StructureConfig({
    required this.hp,
    required this.cost,
    required this.upkeepEnergy,
    required this.moneyPerTick,
    required this.energyPerTick,
    this.range,
    this.fireIntervalMs,
    this.projectileDamage,
    this.projectileSpeed,
  });

  factory StructureConfig.fromJson(Map<String, dynamic> json) =>
      _$StructureConfigFromJson(json);
  Map<String, dynamic> toJson() => _$StructureConfigToJson(this);
}

@JsonSerializable()
class EnemyConfig {
  final int hp;
  final double speed;
  @JsonKey(name: 'contact_damage')
  final int contactDamage;
  @JsonKey(name: 'contact_interval_ms')
  final int contactIntervalMs;
  final int bounty;
  @JsonKey(name: 'target_type')
  final String targetType;

  EnemyConfig({
    required this.hp,
    required this.speed,
    required this.contactDamage,
    required this.contactIntervalMs,
    required this.bounty,
    required this.targetType,
  });

  factory EnemyConfig.fromJson(Map<String, dynamic> json) =>
      _$EnemyConfigFromJson(json);
  Map<String, dynamic> toJson() => _$EnemyConfigToJson(this);
}
