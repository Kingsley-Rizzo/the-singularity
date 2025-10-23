import 'package:json_annotation/json_annotation.dart';

part 'wave_config.g.dart';

@JsonSerializable()
class WaveConfig {
  @JsonKey(name: 'wave_interval_s')
  final int waveIntervalS;
  final List<WaveData> waves;
  final ScalingConfig scaling;

  WaveConfig({
    required this.waveIntervalS,
    required this.waves,
    required this.scaling,
  });

  factory WaveConfig.fromJson(Map<String, dynamic> json) =>
      _$WaveConfigFromJson(json);
  Map<String, dynamic> toJson() => _$WaveConfigToJson(this);
}

@JsonSerializable()
class WaveData {
  final int time;
  final Map<String, int> enemies;

  WaveData({
    required this.time,
    required this.enemies,
  });

  factory WaveData.fromJson(Map<String, dynamic> json) =>
      _$WaveDataFromJson(json);
  Map<String, dynamic> toJson() => _$WaveDataToJson(this);
}

@JsonSerializable()
class ScalingConfig {
  @JsonKey(name: 'hp_mult_per_wave')
  final double hpMultPerWave;
  @JsonKey(name: 'count_mult_per_wave')
  final double countMultPerWave;

  ScalingConfig({
    required this.hpMultPerWave,
    required this.countMultPerWave,
  });

  factory ScalingConfig.fromJson(Map<String, dynamic> json) =>
      _$ScalingConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ScalingConfigToJson(this);
}
