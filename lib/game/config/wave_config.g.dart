// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wave_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaveConfig _$WaveConfigFromJson(Map<String, dynamic> json) => WaveConfig(
      waveIntervalS: (json['wave_interval_s'] as num).toInt(),
      waves: (json['waves'] as List<dynamic>)
          .map((e) => WaveData.fromJson(e as Map<String, dynamic>))
          .toList(),
      scaling: ScalingConfig.fromJson(json['scaling'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WaveConfigToJson(WaveConfig instance) =>
    <String, dynamic>{
      'wave_interval_s': instance.waveIntervalS,
      'waves': instance.waves,
      'scaling': instance.scaling,
    };

WaveData _$WaveDataFromJson(Map<String, dynamic> json) => WaveData(
      time: (json['time'] as num).toInt(),
      enemies: Map<String, int>.from(json['enemies'] as Map),
    );

Map<String, dynamic> _$WaveDataToJson(WaveData instance) => <String, dynamic>{
      'time': instance.time,
      'enemies': instance.enemies,
    };

ScalingConfig _$ScalingConfigFromJson(Map<String, dynamic> json) =>
    ScalingConfig(
      hpMultPerWave: (json['hp_mult_per_wave'] as num).toDouble(),
      countMultPerWave: (json['count_mult_per_wave'] as num).toDouble(),
    );

Map<String, dynamic> _$ScalingConfigToJson(ScalingConfig instance) =>
    <String, dynamic>{
      'hp_mult_per_wave': instance.hpMultPerWave,
      'count_mult_per_wave': instance.countMultPerWave,
    };
