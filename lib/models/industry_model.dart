class IndustryModel {
  final List<Industry> industry;
  final List<Industry> noiconIndustry;

  IndustryModel({
    required this.industry,
    required this.noiconIndustry,
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      industry: (json['industry'] as List?)
              ?.map((e) => Industry.fromJson(e))
              .toList() ??
          [],

      noiconIndustry: (json['noiconIndustry'] as List?)
              ?.map((e) => Industry.fromJson(e))
              .toList() ??
          [],
    );
  }
}
class Industry {
  final String cateName;
  final int catId;
  final String icon;
  final int site;
  final List<String> bindTags;

  Industry({
    required this.cateName,
    required this.catId,
    required this.icon,
    required this.site,
    required this.bindTags,
  });

  factory Industry.fromJson(Map<String, dynamic> json) {
    return Industry(
      cateName: json['cate_name'] ?? '',
      catId: json['cat_id'] ?? 0,
      icon: json['icon'] ?? '',
      site: json['site'] ?? 0,

      bindTags: (json['bind_tags'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}