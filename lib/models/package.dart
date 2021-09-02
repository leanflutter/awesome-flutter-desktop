class Package {
  String name;
  String description;
  String repo;
  String get url => 'https://pub.dev/packages/$name';
  String get githubUrl => 'https://github.com/$repo';
  String get githubBadgeStars =>
      'https://img.shields.io/github/stars/${repo}?style=social';

  String get md {
    String linkedName = '[${name}](${url})';
    String linkedBadgeStars =
        '[![GitHub Repo stars]($githubBadgeStars)]($githubUrl)';
    return '| $linkedName | $linkedBadgeStars | ${description.replaceAll('\n', ' ')} |';
  }

  Package({
    this.name,
    this.description,
    this.repo,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return Package(
      name: json['name'],
      description: json['description'],
      repo: json['repo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'repo': repo,
    };
  }
}
