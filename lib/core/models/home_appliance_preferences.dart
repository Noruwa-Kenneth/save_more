class HomeAppliancePreferences {
  final bool electricHeater;
  final bool heatPump;
  final bool waterHeater;
  final bool refrigerator;
  final bool dishwasher;
  final bool washingMachine;
  final bool dryer;
  final bool electricStove;
  final bool evCharger;

  const HomeAppliancePreferences({
    this.electricHeater = true,
    this.heatPump = false,
    this.waterHeater = true,
    this.refrigerator = true,
    this.dishwasher = false,
    this.washingMachine = true,
    this.dryer = false,
    this.electricStove = true,
    this.evCharger = false,
  });

  bool get hasHeatingAppliance => electricHeater || heatPump || waterHeater;

  bool get hasFlexibleAppliance =>
      dishwasher || washingMachine || dryer || evCharger;

  Map<String, bool> toJson() => {
    'electricHeater': electricHeater,
    'heatPump': heatPump,
    'waterHeater': waterHeater,
    'refrigerator': refrigerator,
    'dishwasher': dishwasher,
    'washingMachine': washingMachine,
    'dryer': dryer,
    'electricStove': electricStove,
    'evCharger': evCharger,
  };

  factory HomeAppliancePreferences.fromJson(Map<String, dynamic> json) {
    const defaults = HomeAppliancePreferences();
    return HomeAppliancePreferences(
      electricHeater: json['electricHeater'] as bool? ?? defaults.electricHeater,
      heatPump: json['heatPump'] as bool? ?? defaults.heatPump,
      waterHeater: json['waterHeater'] as bool? ?? defaults.waterHeater,
      refrigerator: json['refrigerator'] as bool? ?? defaults.refrigerator,
      dishwasher: json['dishwasher'] as bool? ?? defaults.dishwasher,
      washingMachine: json['washingMachine'] as bool? ?? defaults.washingMachine,
      dryer: json['dryer'] as bool? ?? defaults.dryer,
      electricStove: json['electricStove'] as bool? ?? defaults.electricStove,
      evCharger: json['evCharger'] as bool? ?? defaults.evCharger,
    );
  }
}
